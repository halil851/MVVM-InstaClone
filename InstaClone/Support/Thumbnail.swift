//
//  Thumbnail.swift
//  InstaClone
//
//  Created by halil dikişli on 7.06.2023.
//

import UIKit.UIImage
import Firebase
import FirebaseStorage

struct Thumbnail {
    
    var image: UIImage? = UIImage(systemName: "person")
    
    func addNewThumbnail(email: String = currentUserEmail, quality: Quality = .Normal) async {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child(K.profilePictures)
        
        guard let data = image?.jpegData(compressionQuality: quality.rawValue) else {
            print("While compresing an error occur.")
            return}
        
        // File name in server
        let imageRef = mediaFolder.child("\(email).jpg")
        
        do{
            _ = try await imageRef.putDataAsync(data)
            let url = try await imageRef.downloadURL()
            let imageUrl = url.absoluteString
            
            //DATABASE
            let firestoreDatabase = Firestore.firestore()
            var firestoreRef: DocumentReference? = nil
            let firestorePost: [String: Any] = [K.Document.imageUrl : imageUrl,
                                                K.Document.postedBy : currentUserEmail]
            
            //Saving to Firestore Database
            firestoreRef = firestoreDatabase.collection(K.profilePictures).addDocument(data: firestorePost, completion: { err in
                guard err == nil else { return }
                print("Profile Picture has successfully updated to Firebase server")
            })
            
        }catch{
            print(error.localizedDescription)
        }
    }
}
