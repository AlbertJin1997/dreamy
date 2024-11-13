import NIO
import NIOTLS
import NIOSSL
import NIOExtras

class NIOClient {
    static let shared = NIOClient()
    private var group: EventLoopGroup
    private var channel: Channel?
    private var isConnected: Bool = false
    
    private init() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
    
    func connect(host: String, port: Int) {
        // 设置连接引导程序
        let bootstrap = ClientBootstrap(group: group)
            .connectTimeout(TimeAmount.seconds(300))
            .channelInitializer { channel in
                // Define your handlers
                let inboundHandler = SimpleInboundHandler()
                let inboundHandler2 = SimpleInboundHandler()
                let idleStateHandler = IdleStateHandler(readTimeout: TimeAmount.seconds(90),writeTimeout: TimeAmount.seconds(30), allTimeout: TimeAmount.seconds(100))
                let outboundHandler = SimpleOutboundHandler()
                let outboundHandler2 = SimpleOutboundHandler()
                let heartBeatHandler = HeartbeatHandler()
                //let sslHandler = try! MutualTLSClientHandler.createSSLHandler(host: host)
                
                // Return the result of adding handlers, which is an EventLoopFuture
                return channel.pipeline.addHandlers([DebugInboundEventsHandler(), idleStateHandler, heartBeatHandler, inboundHandler, inboundHandler2, outboundHandler, outboundHandler2, DebugOutboundEventsHandler()]).map {
                    // This block runs once the handlers are added successfully
                    print("Handlers added to the pipeline")
                }.flatMapError { error in
                    // Handle any errors that occurred while adding handlers
                    print("Failed to add handlers to the channel: \(error)")
                    return channel.eventLoop.makeFailedFuture(error)  // Return the failure
                }
            }
        bootstrap.connect(host: host, port: port).whenComplete { result in
            switch result {
            case .success(let channel):
                self.channel = channel
                self.isConnected = true
                print("Connected to \(host):\(port)")
            case .failure(let error):
                print("Failed to connect: \(error)")
            }
        }
    }
    
    func send() {
        channel?.writeAndFlush(ByteBuffer(string: "hello world")).whenComplete { result in
            switch result {
            case .success:
                print("Write and flush succeeded")
                // Handle success here
            case .failure(let error):
                print("Write failed with error: \(error)")
                // Handle failure here
            }
        }
    }
    
    func disconnect() {
        if let channel = channel {
            // Close the channel asynchronously without blocking
            channel.close().whenComplete { [self] result in
                switch result {
                case .success(_):
                    isConnected = false
                    print("Disconnected")
                case .failure(let error):
                    print("Failed to connect: \(error)")
                }
            }
        }
    }
    
    private func scheduleReconnect(host: String, port: Int) {
        guard !isConnected else { return }
        let reconnectDelay: TimeAmount = .seconds(5)
        group.next().scheduleTask(in: reconnectDelay) { [weak self] in
            print("Attempting to reconnect...")
            self?.connect(host: host, port: port)
        }
    }
    
    //测试EmbededChannel
    func testEmbededChannel() {
        let decoderHandler = ByteToMessageHandler(MyProtocolDecoder())
        let inboundHandler = SimpleInboundHandler()
        let inboundHandler2 = SimpleInboundHandler()
        let idleStateHandler = IdleStateHandler(readTimeout: TimeAmount.seconds(0),writeTimeout: TimeAmount.seconds(3), allTimeout: TimeAmount.seconds(0))
        let outboundHandler = SimpleOutboundHandler()
        let outboundHandler2 = SimpleOutboundHandler()
        let encoderHandler = MessageToByteHandler(MyProtocolEncoder())
        
        let channel = EmbeddedChannel(handlers: [decoderHandler, inboundHandler, outboundHandler, encoderHandler])
        do {
            let buf = ByteBuffer(string: "hello world")
            try channel.writeInbound(createByteBuffer(from: MyMessage(length: Int32(buf.readableBytes), body: buf)))
            //try channel.writeOutbound(MyMessage(length: Int32(buf.readableBytes), body: buf))
        }
        catch {
            print("error")
        }
        
        
        
        //测试byteBuffer
        var buf = ByteBuffer()
        print(buf)
        var str = ""
        for _ in 0...5 {
            str.append("a")
        }
        buf.writeBytes(str.data(using: .utf8)!)
        print(buf.debugDescription)
        print(buf.getString(at: 0, length: buf.readableBytes)!)
        var buf1 = buf.getSlice(at: 0, length: 3)
        var buf2 = buf.getSlice(at: 3, length: 3)
        buf1?.setString("h", at: 0)
        buf2?.setString("t", at: 0)
        print("======================")
        print(buf1!.getString(at: 0, length: buf1!.readableBytes)!)
        print(buf2!.getString(at: 0, length: buf2!.readableBytes)!)
        print(buf.getString(at: 0, length: buf.readableBytes)!)
        
        // 创建一个 ByteBuffer
        var buffer = ByteBufferAllocator().buffer(capacity: 20)
        buffer.writeString("Hello, NIO!")
        
        // 对 ByteBuffer 进行切片
        var slice = buffer.getSlice(at: 7, length: 3)!
        var slice1 = buffer.getSlice(at: 0, length: 5)!
        
        // 使用 setString 修改切片中的内容
        slice.setString("IO!", at: 0)
        
        
        // 打印原始 buffer 和切片
        print("Original buffer: \(buffer.getString(at: 0, length: buffer.readableBytes) ?? "")")  // 输出: Hello, NIO!
        print("Slice: \(slice.getString(at: 0, length: slice.readableBytes) ?? "")")  // 输出: IO!
        
        
        var newbuffer = ByteBufferAllocator().buffer(capacity: 20)
        newbuffer.writeBuffer(&slice)
        newbuffer.writeBuffer(&slice1)
        print("newbuffer: \(newbuffer.getString(at: 0, length: newbuffer.readableBytes) ?? "")")  // 输出:
    }
}
