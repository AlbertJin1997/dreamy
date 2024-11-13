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
            
            Button("test trade") {
                NIOClient.shared.connect(host: "lucymocktrade.qiuer.cc", port: 9932)
            }.padding()
            
            Button("test manager") {
                ClientManager.shared.connect(host: "8.135.10.183", port: 31519)
            }.padding()
            
            
            Button("test manager send") {
                ClientManager.shared.sendMessage("from Client") { str in
                    print("jpf  " + str)
                }
            }.padding()
        }
    }
}

#Preview {
    SwiftNioPage()
}
