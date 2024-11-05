import NIO
import NIOTLS
import NIOSSL

struct CustomMessageHeader {
    var totalLen: UInt32
    var serialNo: UInt32
    var funcId: UInt16
    var version: UInt8
    var reserved: Int32
    var data: Data?
    
    func toByteBuffer() -> ByteBuffer {
        var buffer = ByteBufferAllocator().buffer(capacity: MemoryLayout<CustomMessageHeader>.size)
        buffer.writeInteger(totalLen, as: UInt32.self)
        buffer.writeInteger(serialNo, as: UInt32.self)
        buffer.writeInteger(funcId, as: UInt16.self)
        buffer.writeInteger(version, as: UInt8.self)
        buffer.writeInteger(reserved, as: Int32.self)
        if let data = data {
            buffer.writeInteger(UInt32(data.count), as: UInt32.self)
            buffer.writeBytes(data)
        }
        return buffer
    }
    
    static func fromByteBuffer(buffer: inout ByteBuffer) -> CustomMessageHeader? {
        guard buffer.readableBytes >= MemoryLayout<CustomMessageHeader>.size else {
            return nil
        }
        let totalLen = buffer.readInteger(as: UInt32.self)!
        let serialNo = buffer.readInteger(as: UInt32.self)!
        let funcId = buffer.readInteger(as: UInt16.self)!
        let version = buffer.readInteger(as: UInt8.self)!
        let reserved = buffer.readInteger(as: Int32.self)!
        let dataLength = buffer.readInteger(as: UInt32.self)!
        let dataBytes = buffer.readBytes(length: Int(dataLength))
        let data = dataBytes.flatMap { Data($0) }
        return CustomMessageHeader(totalLen: totalLen, serialNo: serialNo, funcId: funcId, version: version, reserved: reserved, data: data)
    }
}

extension ByteBuffer {
    func toData() -> Data {
        return Data(self.readableBytesView)
    }
}

func createHeartBeatHeader(flowNo: UInt32) -> CustomMessageHeader {
    let funcId: UInt16 = 1 // 假设 1 为心跳包功能 ID
    let version: UInt8 = 1
    let reserved: Int32 = 0 // 根据需要设置
    
    let header = CustomMessageHeader(
        totalLen: UInt32(MemoryLayout<CustomMessageHeader>.size),
        serialNo: flowNo,
        funcId: funcId,
        version: version,
        reserved: reserved
    )
    
    return header
}

class NIOClient {
    static let shared = NIOClient()
    private var group: EventLoopGroup
    private var channel: Channel?
    private var heartbeatTask: Scheduled<Void>?
    private var isConnected: Bool = false
    private var flowNo: UInt32 = 1
    private var heartbeatRetryCount: Int = 0
    private let maxHeartbeatRetries: Int = 3
    private let baseHeartbeatRetryDelay: TimeAmount = .seconds(2)
    
    private init() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
    
    func connect(host: String, port: Int) {
        // 加载客户端证书和私钥
        let clientCertificate: NIOSSLCertificate
        let privateKey: NIOSSLPrivateKey
        let caPath = Bundle.main.path(forResource: "ca", ofType: "cer") ?? ""
        let clientCerPath = Bundle.main.path(forResource: "client_cer", ofType: "pem") ?? ""
        let clientPath = Bundle.main.path(forResource: "client_private", ofType: "pem") ?? ""
        do {
            clientCertificate = try NIOSSLCertificate.fromPEMFile(caPath)[0]
            privateKey = try NIOSSLPrivateKey(file: clientPath, format: .pem)
        } catch {
            print("Failed to load certificate or private key: \(error)")
            return;
        }
        
        // 设置 TLS 配置
        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsConfiguration.certificateChain = [.certificate(clientCertificate)]
        tlsConfiguration.privateKey = .privateKey(privateKey)
        tlsConfiguration.trustRoots = .certificates(try! NIOSSLCertificate.fromPEMFile(clientCerPath))
        
        // 创建 SSL 上下文
        let sslContext: NIOSSLContext
        do {
            sslContext = try NIOSSLContext(configuration: tlsConfiguration)
        } catch {
            print("Failed to create SSL context: \(error)")
            return
        }
        
        // 设置连接引导程序
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { channel in
                do {
                    let sslHandler = try NIOSSLClientHandler(context: sslContext, serverHostname: host)
                    return channel.pipeline.addHandlers([sslHandler, self]).map { _ in }
                } catch {
                    print("Failed to add handlers to the channel: \(error)")
                    return channel.eventLoop.makeFailedFuture(error)
                }
            }
        
        bootstrap.connect(host: host, port: port).whenComplete { result in
            switch result {
            case .success(let channel):
                self.channel = channel
                self.isConnected = true
                print("Connected to \(host):\(port)")
                self.startHeartbeat(host: host, port: port)
            case .failure(let error):
                print("Failed to connect: \(error)")
                self.scheduleReconnect(host: host, port: port)
            }
        }
    }
    
    
    
    func disconnect() {
        heartbeatTask?.cancel()
        if let channel = channel {
            // Close the channel asynchronously without blocking
            channel.close(promise: nil)
        }
        isConnected = false
        print("Disconnected")
    }
    
    
    private let taskQueue = DispatchQueue(label: "heartbeatTaskQueue")
    
    private func startHeartbeat(host: String, port: Int) {
        taskQueue.sync {
            heartbeatTask?.cancel()
        }
        
        heartbeatTask = channel?.eventLoop.scheduleTask(in:.seconds(3)) { [weak self] in
            guard let self = self, let channel = self.channel else { return }
            
            let header = createHeartBeatHeader(flowNo: self.flowNo)
            self.flowNo += 1
            channel.writeAndFlush(header.toByteBuffer()).whenComplete { result in
                switch result {
                case.success:
                    print("Sent heartbeat")
                    self.heartbeatRetryCount = 0
                case.failure(let error):
                    print("Failed to send heartbeat: \(error)")
                    self.heartbeatRetryCount += 1
                    if self.heartbeatRetryCount <= self.maxHeartbeatRetries {
                        let retryDelay = self.baseHeartbeatRetryDelay * (1 << (self.heartbeatRetryCount - 1))
                        channel.eventLoop.scheduleTask(in: retryDelay) {
                            self.startHeartbeat(host: host, port: port)
                        }
                    } else {
                        self.disconnect()
                        self.scheduleReconnect(host: host, port: port)
                    }
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
}

extension NIOClient: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    private func channelRead(context: ChannelHandlerContext, data: inout NIOClient.InboundIn) {
        if let stringData = data.getString(at: 0, length: data.readableBytes) {
            print("Received message: \(stringData)")
        } else {
            print("Failed to convert received data to string.")
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error caught: \(error)")
        context.close(promise: nil)
        disconnect()
        scheduleReconnect(host: "localhost", port: 8080)
    }
}
