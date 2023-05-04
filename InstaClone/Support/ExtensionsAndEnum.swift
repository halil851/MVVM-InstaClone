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

enum Action {
    case Like
    case NoMoreLiking
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


