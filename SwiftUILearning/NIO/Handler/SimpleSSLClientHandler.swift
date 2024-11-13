//
//  SimpleSSLClientHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/12.
//

import NIOSSL
import NIO

class MutualTLSClientHandler {
    
    // 返回配置好的 NIOSSLHandler，支持双向认证
    static func createSSLHandler(host: String) throws -> NIOSSLHandler {
        let caPath = Bundle.main.path(forResource: "ca", ofType:".cer") ??  ""
        let clientPath = Bundle.main.path(forResource: "client_cer", ofType:".pem") ??  ""
        let clientKey = Bundle.main.path(forResource: "client_private", ofType:".pem") ??  ""
        
        var configurationClient =  TLSConfiguration.makeClientConfiguration();
        //        configurationClient.cipherSuiteValues = [.TLS_RSA_WITH_AES_256_CBC_SHA]
        //        configurationClient.signingSignatureAlgorithms = [.rsaPkcs1Sha256]
        //        configurationClient.verifySignatureAlgorithms = [.rsaPkcs1Sha256]
        
        configurationClient.certificateChain = try! NIOSSLCertificate.fromPEMFile(clientPath).map{.certificate($0)}
        configurationClient.privateKey = .file(clientKey)
        
        let trustRoot = try! NIOSSLCertificate.fromPEMFile(caPath)
        configurationClient.trustRoots = NIOSSLTrustRoots.certificates([trustRoot[0]])
        let sslContext = try! NIOSSLContext(configuration: configurationClient)
        let sslHandler = try! NIOSSLClientHandler(context:sslContext, serverHostname:host)
        
        return sslHandler
    }
}


