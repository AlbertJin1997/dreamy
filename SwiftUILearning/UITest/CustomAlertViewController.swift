//
//  CustomAlertViewController.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/25.
//

import UIKit
import SnapKit
import Foundation

class CustomAlertViewController: UIViewController, UITextViewDelegate {
    
    private var titleText: String?
    private var messageText: String?
    private var buttonActions: [(String, (() -> Void)?)] = []
    private var clickableText: String?
    private var linkAction: ((String) -> Void)?  // 让 linkAction 接受点击的文本
    
    // MARK: - UI Elements
    private var titleLabel: UILabel!
    private var messageLabel: UITextView!
    private var stackView: UIStackView!
    
    // 公共初始化方法
    static func showAlert(on viewController: UIViewController , title: String, message: String, clickableText: String? = nil, buttons: [(String, () -> Void)] = [], linkAction: ((String) -> Void)? = nil) {
        let alertVC = CustomAlertViewController()
        alertVC.titleText = title
        alertVC.messageText = message
        alertVC.clickableText = clickableText
        alertVC.buttonActions = buttons
        alertVC.linkAction = linkAction
        alertVC.modalPresentationStyle = .overFullScreen
        
        // Show the alert
        viewController.present(alertVC, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        // Container view for alert
        let alertView = UIView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        self.view.addSubview(alertView)
        
        alertView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.width.equalTo(300)
        }
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        alertView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(alertView).offset(20)
            make.left.equalTo(alertView).offset(20)
            make.right.equalTo(alertView).offset(-20)
        }
        
        // Message TextView
        messageLabel = UITextView()
        messageLabel.text = messageText
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.isEditable = false
        messageLabel.delegate = self  // Set the delegate to self
        messageLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        
        if let clickableText = clickableText, let message = messageText {
            let fullText = NSMutableAttributedString(string: message)
            if let range = message.range(of: clickableText) {
                let nsRange = NSRange(range, in: message)
                fullText.addAttribute(.link, value: clickableText, range: nsRange)  // Pass clickable text as the link value
            }
            messageLabel.attributedText = fullText
        }
        
        alertView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(alertView).offset(20)
            make.right.equalTo(alertView).offset(-20)
            make.height.equalTo(100)
        }
        
        // Buttons Stack View
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        alertView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.left.equalTo(alertView).offset(20)
            make.right.equalTo(alertView).offset(-20)
            make.bottom.equalTo(alertView).offset(-20)
        }
        
        // Add buttons to stack view
        for (title, action) in buttonActions {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addAction(UIAction(handler: { _ in
                action?()
                self.dismiss(animated: false, completion: nil)
            }), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        // Ensure the messageLabel has text and the range is valid within that text
        guard let text = self.messageLabel.text,
              let range = Range(textItem.range, in: text) else {
            // If the text or range is invalid, return the default action
            return defaultAction
        }
        
        // Extract the substring corresponding to the range
        let substring = text[range]
        
        // Call the linkAction if it exists
        if let linkAction = self.linkAction {
            linkAction(String(substring))  // Convert the Substring to String and invoke the action
            self.dismiss(animated: false, completion: nil)
        }
        
        // Return the default action, whether or not the linkAction was triggered
        return defaultAction
    }

}


func topViewController() -> UIViewController? {
    // 获取当前活动的窗口场景
    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
        return nil
    }
    
    // 获取主窗口
    guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
        return nil
    }

    // 递归查找最上层的 presented view controller
    var topVC = rootViewController
    while let presentedVC = topVC.presentedViewController {
        topVC = presentedVC
    }

    return topVC
}


