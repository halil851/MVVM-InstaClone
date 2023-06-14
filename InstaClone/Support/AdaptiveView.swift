//
//  AdaptiveView.swift
//  InstaClone
//
//  Created by halil dikişli on 6.06.2023.
//

import UIKit

/// When keyboard active, View goes up dynamically
class AdaptiveViewKeyboardSetup {
    
    private weak var view: UIView?
    private var position: CGRect?
    private var freezeView: [UIView]
    private var amountOfViewSwipeUp: CGFloat = 0
    ///  View goes up depend on the position you chose.
    ///  If you want to freeze some view, use freezeView, and they stay still, can be selected multiple view.
    ///  Use position to calculate how View goes up.
    init(view: UIView, position: CGRect, freezeView: [UIView] = [UIView()] ) {
        self.view = view
        self.position = position
        self.freezeView = freezeView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let view = view,
              let position = position,
              let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        let screenHeight = UIScreen.main.bounds.size.height
        let distanceFromBottom = screenHeight - position.maxY
        
        guard distanceFromBottom < keyboardSize.height else {return}
        amountOfViewSwipeUp = keyboardSize.height - distanceFromBottom
        amountOfViewSwipeUp *= 1.1
        
        stayStill(willKeyboardShow: true)
        
        if view.frame.origin.y == 0 {
            view.frame.origin.y -= amountOfViewSwipeUp
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let view = view else {return}
        stayStill(willKeyboardShow: false)
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
   /// Keep still freezeView.
    private func stayStill(willKeyboardShow: Bool) {
        UIView.animate(withDuration: 0) {
            for view in self.freezeView {
                view.transform = CGAffineTransform(translationX: 0, y: willKeyboardShow == true ? self.amountOfViewSwipeUp : 0)
            }
            
        }
    }
}

