//
//  AdaptiveView.swift
//  InstaClone
//
//  Created by halil dikişli on 6.06.2023.
//

import UIKit

class AdaptiveViewKeyboardSetup {
    
    private weak var view: UIView?
    private weak var button: UIButton?
    
    init(view: UIView, button: UIButton) {
        self.view = view
        self.button = button
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let view = view,
              let button = button,
              let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        
        let screenHeight = windowScene.screen.bounds.size.height
        let heightOfSignInButtonFromBottom = screenHeight - button.frame.maxY
        
        guard heightOfSignInButtonFromBottom < keyboardSize.height else {return}
        let upValue = keyboardSize.height - heightOfSignInButtonFromBottom + heightOfSignInButtonFromBottom * 0.15
        
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= upValue
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let view = view else {return}
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
