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

enum Quality: CGFloat {
    case lossless = 1.0
    case good = 0.6
    case normal = 0.3
    case low = 0.1
}

enum Action {
    case like
    case noMoreLiking
}

enum ErrorTypes: LocalizedError {
    case noImageUrl
    case noDocumentId
    case invalidUrl
    case imageLoadFailed

    var errorDescription: String? {
        switch self {
        case .noImageUrl:
            return "No image URL found in Firestore snapshot"
        case .noDocumentId:
            return "No document ID found in Firestore snapshot"
        case .invalidUrl:
            return "Invalid image URL"
        case .imageLoadFailed:
            return "Failed to load image"
        }
    }
}

extension UITextField {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
extension UITextView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

