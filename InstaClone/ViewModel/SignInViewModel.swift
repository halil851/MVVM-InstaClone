//
//  LogInViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 22.03.2023.
//

import Firebase
import FirebaseStorage
import UIKit.UIImage

var currentUserEmail: String = Auth.auth().currentUser?.email ?? "No One"

struct SignInViewModel: SignInVCProtocol {
    func signInManager(email: String, password: String, completionHandler: @escaping(Error?)->() ) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, err in
            completionHandler(err)
        }
    }
    
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?)->() )  {
        Auth.auth().createUser(withEmail: email, password: password) { authData, err in
            if err == nil {
                print("Default photo will upload.")
                addDefaultProfilePicture(userName: email)
            }
            completionHandler(err)
            
        }
    }
    
    func addDefaultProfilePicture(userName: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child(K.profilePictures)
        
        let image = UIImage(systemName: "person")
        guard let data = image?.jpegData(compressionQuality: 0.3) else {
            print("While compresing an error occur.")
            return}
        
        // File name in server
        let imageRef = mediaFolder.child("\(userName).jpg")
        
        imageRef.putData(data, metadata: nil) { metaData, err in
            guard err == nil else {
                return
            }
            
            
            imageRef.downloadURL { url, error in
                guard error == nil else{return}
                
                guard let imageUrl = url?.absoluteString else {return}
                
                //DATABASE
                let firestoreDatabase = Firestore.firestore()
                var firestoreRef: DocumentReference? = nil
                let firestorePost: [String: Any] = [K.Document.imageUrl : imageUrl,
                                                    K.Document.postedBy : currentUserEmail]
                
                //Saving to Firestore Database
                firestoreRef = firestoreDatabase.collection(K.profilePictures).addDocument(data: firestorePost, completion: { err in
                    guard err == nil else {
                        return
                    }
                    print("Default Profile Picture has successfully uploaded to Firebase server")
                })
                
            }
            
        }
        
    }
}


