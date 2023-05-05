//
//  ProfileViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import Firebase
import FirebaseStorage
import SDWebImage


class ProfileViewModel {
    
    private let db = Firestore.firestore()
//    private var myDict = [[String: (UIImage, String)]]()
    
    func getUsersPosts(with userEmail: String,completion: @escaping(UIImage, _ isReadyToReload: Bool) -> Void) {
        
        let query = db.collection(K.Posts)
            .whereField(K.Document.postedBy, isEqualTo: userEmail)
            .order(by: K.Document.date, descending: true)
        
        query.getDocuments { snapshot, err in
            if err != nil {
                print(err.debugDescription)
                return}
            
            guard let snapshot = snapshot else {
                print(err.debugDescription)
                return}
            var isReadyToReload = false
            
            for document in snapshot.documents {
                
                guard let imageUrlString = document.get(K.Document.imageUrl) as? String  else {return}
                let imageURL = URL(string: imageUrlString)
                
                SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, data, error, cacheType, finished, _ in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let image = image else {return}
                    
                    if document == snapshot.documents.last { isReadyToReload = true}
                    
                    completion(image, isReadyToReload)
                }
                
                
            }
            
        }
    }
    
}

extension ProfileViewModel {
   
    func addProfilePicture(image: UIImageView, completion: (() -> Void)? = nil) {
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
                    print("Profile Picture has successfully updated to Firebase server")
                    completion?()
                })
                
            }
            
        }
        
    }
     
  
    
    func getProfilePicture(who: String = currentUserEmail, isRequestFromProfilePage: Bool = false) async throws -> (UIImage, String) {
            
        let query = db.collection(K.profilePictures)
            .whereField(K.Document.postedBy, isEqualTo: who)

        let snapshot = try await query.getDocuments()
        
        guard let imageUrlString = snapshot.documents.first?.get(K.Document.imageUrl) as? String else {
            throw ErrorTypes.noImageUrl
        }
        guard let id = snapshot.documents.first?.documentID else {
            throw ErrorTypes.noDocumentId
        }
        
        let imageURL = URL(string: imageUrlString)
        let image =  try await loadImage(with: imageURL)
        
//        myDict.append([who: (image, id)])
        
        return (image, id)
    }

    func loadImage(with url: URL?) async throws -> UIImage {
        guard let url = url else {
            throw ErrorTypes.invalidUrl
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            SDWebImageManager.shared.loadImage(with: url, progress: nil) { image, _, error, _, _, _ in
                
                switch (image, error) {
                case let (_, error?):
                    continuation.resume(throwing: error)
                case let (image?, _):
                    continuation.resume(returning: image)
                default:
                    continuation.resume(throwing: ErrorTypes.imageLoadFailed)
                }
            }
        }
    }

   

    func deleteProfilePicture(id: String, completion: @escaping (_ isSuccesDeleting: Bool) -> Void) {
        print("silinmeye çalışılan ID: \(id)")
        //Delete fields in selected document
        db.collection(K.profilePictures).document(id).updateData([K.Document.imageUrl: FieldValue.delete(),
                                                                  K.Document.postedBy: FieldValue.delete()]) { err in
            if let err = err {
                print("Error deleting document: \(err)")
                return
            } else {
                print("Old Documents successfully deleted from Firebase Database")
            }
        }
        
        //Delete document ID
        db.collection(K.profilePictures).document(id).delete { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(false)
            } else {
                print("Old Document ID successfully removed!")
                print("Ready to upload new one.")
                completion(true)
            }
        }
        //MARK: - No need to delete the last picture from Firebase storage, because overwriten
        /*
        //Delete photo from Firebase storage
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file to delete
        let photoPath = storageRef.child(K.profilePictures).child("\(currentUserEmail).jpg")
        // Delete the file
        photoPath.delete { error in
          if let error = error {
              print(error.localizedDescription)
              print("Maybe There are not any Profile Picture belong to current user.")
              completion(false)
          } else {
              print("File deleted successfully from Firebase Storage")
              completion(true)
          }
        }
         */
        
    }
}
