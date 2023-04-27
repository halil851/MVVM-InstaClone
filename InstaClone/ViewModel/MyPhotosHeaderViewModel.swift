//
//  MyPhotosHeaderViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 27.04.2023.
//

import Firebase
import FirebaseStorage
import SDWebImage

struct MyPhotosHeaderViewModel {
    
    func getProfilePicture(completion: @escaping (UIImage)-> Void) {
        let db = Firestore.firestore()
        let query = db.collection(K.profilePictures)
            .whereField(K.Document.postedBy, isEqualTo: currentUserEmail)
        
        query.getDocuments { snapshot, err in
            if err != nil {
                print(err.debugDescription)
                return}
            
            guard let snapshot = snapshot else {
                print(err.debugDescription)
                return}
            
            guard let imageUrlString = snapshot.documents.first?.get(K.Document.imageUrl) as? String else {return}
            let imageURL = URL(string: imageUrlString)
            
            SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, data, error, cacheType, finished, _ in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                
                guard let image = image else {return}
                
                completion(image)
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    func addProfilePicture(image: UIImageView) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child(K.profilePictures)
        
        guard let data = image.image?.jpegData(compressionQuality: 0.3) else {
            print("While compresing an error occur.")
            return}
        
        // File name in server
        let imageRef = mediaFolder.child("\(currentUserEmail).jpg")
        
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
                    
                })
                
            }
            
        }
        
    }
    
}
