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
    var viewModel = MyPhotosHeaderViewModel()
    var id = String()
    
    weak var delegate: HeaderViewToProfileVCProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.text = currentUserEmail
        setImageInteractable()
        
        viewModel.getProfilePicture() { image, id in
            self.profilePicture.image = image
            guard let id = id else {return}
            self.id = id
            print("awakeFromNib ID: \(id)")
            
            
        }
        
        print("profilePicture.frame.width: \(profilePicture.frame.width)")
        print("profilePicture.frame.height: \(profilePicture.frame.height)")

        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        
        
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
        // Make ImageView Circle
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        
        //If it is first picture then avoid deleting a file which doesn't exist
        if self.profilePicture.image == UIImage(systemName: "person") {
            profilePicture.image = image
            viewModel.addProfilePicture(image: profilePicture, completion: {
                self.viewModel.getProfilePicture(isRequestFromProfilePage: true) { _, id in
                    guard let id = id else {return}
                    self.id = id
                }
            })
            
            
        } else {
            viewModel.deleteProfilePicture(id: id, completion: { [self] isSuccessDeleting in
                
                if isSuccessDeleting {
                    profilePicture.image = image
                    viewModel.addProfilePicture(image: profilePicture) {
                        self.viewModel.getProfilePicture(isRequestFromProfilePage: true) { _, id in
                            print(id)
                            guard let id = id else {return}
                            self.id = id
                        }
                    }
                }
            })
            
        }
        MyPhotosHeaderViewModel.isNewProfilePicture = true
        
        picker.dismiss(animated: true)
        
    }
    
   

}
