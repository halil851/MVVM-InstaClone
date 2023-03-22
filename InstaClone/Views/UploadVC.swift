//
//  UploadVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import FirebaseStorage
import Firebase

class UploadVC: UIViewController {
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var uploadOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.delegate = self
        setImageInteractable()
        
    }
    
    func setImageInteractable() {
        image.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTap)
        image.image = UIImage(named: "select3")
    }
    
    @IBAction func uploadTap(_ sender: UIButton) {
        
        if image.image == UIImage(named: "select3") {
            showAlert(mainTitle: "Select image", message: "Select an image before update!", actionButtonTitle: "OK")
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let mediaFolder = storageRef.child("media")
        
        guard let data = image.image?.jpegData(compressionQuality: 0.4) else {
            print("While compresing an error occur.")
            return}
        
        // File name in server
        let uuid = UUID().uuidString
        let imageRef = mediaFolder.child("\(uuid).jpg")
        
        imageRef.putData(data, metadata: nil) { metaData, err in
            guard err == nil else {
                self.showAlert(mainTitle: "Error!", message: err?.localizedDescription ?? "Error in metadata", actionButtonTitle: "OK")
                return
            }
            
            imageRef.downloadURL { url, error in
                guard error == nil else{return}
                
                let imageUrl = url?.absoluteString
                
                //DATABASE
                let firestoreDatabase = Firestore.firestore()
                var firestoreRef: DocumentReference? = nil
                var firestorePost = [K.Document.imageUrl   : imageUrl!,
                                     K.Document.postedBy   : Auth.auth().currentUser!.email!,
                                     K.Document.postComment: self.commentText.text!,
                                     K.Document.date       : FieldValue.serverTimestamp(),
                                     K.Document.likes      : 0]
                
                //Saving to Firestore Database
                firestoreRef = firestoreDatabase.collection(K.Posts).addDocument(data: firestorePost, completion: { err in
                    guard err == nil else {
                        self.showAlert(mainTitle: "Error", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                        return
                    }
                    //Go to Feed when uploading is done
                    self.commentText.text = ""
                    self.image.image = UIImage(named: "select3")
                    self.tabBarController?.selectedIndex = 0
                })
                
            }
        }
        
    }
    
    @IBAction func cancelTap(_ sender: UIButton) {
        self.image.image = UIImage(named: "select3")
        self.commentText.text = ""
    }
    
}

extension UploadVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
}

extension UploadVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentText.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentText.endEditing(true)
    }
    
    
}
