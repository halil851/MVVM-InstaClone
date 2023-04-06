//
//  UploadViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import FirebaseStorage
import Firebase
import UIKit.UIImageView


struct UploadViewModel {
    
    func uploadData(image: UIImageView,comment: String , completionHandler: @escaping(Error?)->()) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child(K.media)
        
        guard let data = image.image?.jpegData(compressionQuality: 0.4) else {
            print("While compresing an error occur.")
            return}
        
        // File name in server
        let uuid = UUID().uuidString
        let imageRef = mediaFolder.child("\(uuid).jpg")
        
        imageRef.putData(data, metadata: nil) { metaData, err in
            guard err == nil else {
                completionHandler(err)
                return
            }
            
            imageRef.downloadURL { url, error in
                guard error == nil else{return}
                
                guard let currentUserEmail = Auth.auth().currentUser?.email,
                      let imageUrl = url?.absoluteString else {return}
                
                //DATABASE
                let firestoreDatabase = Firestore.firestore()
                var firestoreRef: DocumentReference? = nil
                let firestorePost: [String: Any] = [K.Document.imageUrl   : imageUrl,
                                                    K.Document.postedBy   : currentUserEmail,
                                                    K.Document.postComment: comment,
                                                    K.Document.date       : FieldValue.serverTimestamp(),
                                                    K.Document.likedBy    : [],
                                                    K.Document.storageID  : "\(uuid).jpg"]
                
                //Saving to Firestore Database
                firestoreRef = firestoreDatabase.collection(K.Posts).addDocument(data: firestorePost, completion: { err in
                    guard err == nil else {
                        completionHandler(err)
                        return
                    }
                    
                })
                
            }
            
        }
        
    }
    
}
