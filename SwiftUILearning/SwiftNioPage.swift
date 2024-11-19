//
//  SwiftNioPage.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/11.
//

import SwiftUI

struct SwiftNioPage: View {
    var body: some View {
        VStack {
            Button("connect") {
                NIOClient.shared.connect(host: "8.135.10.183", port: 31519)
            }
            .padding()
            
            Button("send") {
                NIOClient.shared.send()
            }
            .padding()
            
            Button("close") {
                NIOClient.shared.disconnect()
            }
            .padding()
            
            Button("test promise") {
                TestPromise.testPromise()
            }.padding()
            
            Button("test EmbededChannel") {
                NIOClient.shared.testEmbededChannel()
            }.padding()
            
            Button("test zhuque") {
                ClientManager.shared.connect(host: "101.230.113.156", port: 8989)
            }.padding()
            
            Button("test manager") {
                ClientManager.shared.connect(host: "8.135.10.183", port: 31519)
            }.padding()
            
            
            Button("test manager subscirbe") {
                var message =  Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeRequest()
                message.themeURL = "/system/echo"
                message.subFlag = true
                ClientManager.shared.sendMessage(message) { response in
                    if (!response.success) {
                        print(response.errMsg)
                        return
                    }
                    guard let rsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeResponse else {
                        return
                    }
                    print("订阅消息回复 isError" + String(rsp.rspInfo.isError))
                }
            }.padding()
            
            Button("test manager close") {
                ClientManager.shared.close()
            }.padding()
        }
    }
}

#Preview {
    SwiftNioPage()
}
