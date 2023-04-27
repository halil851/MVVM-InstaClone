//
//  HeaderView.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

protocol HeaderViewToProfileVCProtocol: AnyObject {
    func pickerPresent(picker: UIImagePickerController)
}

class MyPhotosHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: HeaderViewToProfileVCProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.text = currentUserEmail
        setImageInteractable()
        
    }
    
    private func setImageInteractable() {
        profilePicture.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        profilePicture.addGestureRecognizer(imageTap)
    }
    
   
}

extension MyPhotosHeaderView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc func selectProfilePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        delegate?.pickerPresent(picker: picker)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Selected item is not an image")
            return
        }
        // ImageView'ı yuvarlak hale getirme
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        profilePicture.clipsToBounds = true

        profilePicture.image = image
        picker.dismiss(animated: true)
        
    }
    
   

}
