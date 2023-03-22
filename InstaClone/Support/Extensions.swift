//
//  Extensions.swift
//  InstaClone
//
//  Created by halil dikişli on 21.03.2023.
//

import UIKit

extension UIViewController {
    func showAlert(mainTitle: String, message: String, _ style: UIAlertController.Style = .alert, actionButtonTitle: String, actionStyle: UIAlertAction.Style = .default){
        let alert = UIAlertController(title: mainTitle, message: message, preferredStyle: style)
        let okButton = UIAlertAction(title: actionButtonTitle, style: actionStyle)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
