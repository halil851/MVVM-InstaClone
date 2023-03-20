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
    
    let vc = ViewController()

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var uploadOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setImageInteractable()
        
    }
    
    func showAlert(title: String, message: String, _ style: UIAlertController.Style, actionTitle: String, actionStyle: UIAlertAction.Style){
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okButton = UIAlertAction(title: actionTitle, style: actionStyle)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setImageInteractable() {
        image.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTap)
        image.image = UIImage(named: "select3")
    }
    
    @IBAction func uploadTap(_ sender: UIButton) {
        
        if image.image == UIImage(named: "select3") {
            showAlert(title: "Select image", message: "Select an image before update!", .alert, actionTitle: "OK", actionStyle: .default)
            return
        }

        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let mediaFolder = storageRef.child("media")
        
        guard let data = image.image?.jpegData(compressionQuality: 0.4) else {
            print("nil")
            return}
        
        // File name in server
        let uuid = UUID().uuidString
        let imageRef = mediaFolder.child("\(uuid).jpg")
        
        imageRef.putData(data, metadata: nil) { metaData, err in
            guard err == nil else {
                print(err?.localizedDescription ?? "Error in metadata")
                self.showAlert(title: "Error!", message: err?.localizedDescription ?? "Error", .alert, actionTitle: "deneee", actionStyle: .default)
                return
            }
            
            imageRef.downloadURL { url, error in
                guard error == nil else{return}
                
                let imageUrl = url?.absoluteString
                
                //DATABASE
                let firestoreDatabase = Firestore.firestore()
                var firestoreRef: DocumentReference? = nil
                var firestorePost = ["imageUrl": imageUrl!,
                                     "postedBy": Auth.auth().currentUser!.email!,
                                     "postComment": self.commentText.text!,
                                     "date": FieldValue.serverTimestamp(),
                                     "likes": 0]
                
                //Saving to Firestore Database
                firestoreRef = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { err in
                    guard err == nil else {
                        self.showAlert(title: "Error", message: err?.localizedDescription ?? "Error", .alert, actionTitle: "Error", actionStyle: .default)
                        return
                    }
                    //Go to Feed
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
