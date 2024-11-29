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
                GFTeemoClientManager.shared.connect(host: "101.230.113.156", port: 8989)
            }.padding()
            
            Button("test manager") {
                GFTeemoClientManager.shared.connect(host: "8.135.10.183", port: 31519)
            }.padding()
            
            
            Button("test manager subscirbe") {
                print(String(describing: Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeRequest.self))
                var message =  Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeRequest()
                message.themeURL = "/system/codetable"
                message.subFlag = true
                GFTeemoClientManager.shared.sendMessage(message: message) { response in
                    if (!response.success) {
                        print("subsrible error:" + response.errMsg)
                        return
                    }
                    guard let rsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeResponse else {
                        return
                    }
                    print("订阅消息回复 isError" + String(rsp.rspInfo.isError))
                }
            }.padding()
            
            Button("test manager close") {
                GFTeemoClientManager.shared.close()
            }.padding()
            
            Button("test alert") {
                CustomAlertViewController.showAlert(
                            on:topViewController()!,
                            title: "自定义弹窗",
                            message: "这是一个包含链接的弹窗。点击这里跳转。",
                            clickableText: "点击这里",
                            buttons: [("t", {}),("t1", {}),("t12", {})],
                            linkAction: {text in 
                                print("链接被点击，执行跳转操作！\(text)")
                            }
                        )
            }
        }
    }
}

#Preview {
    SwiftNioPage()
}
