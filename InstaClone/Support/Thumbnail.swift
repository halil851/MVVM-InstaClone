//
//  Thumbnail.swift
//  InstaClone
//
//  Created by halil dikişli on 7.06.2023.
//

import UIKit.UIImage
import Firebase
import FirebaseStorage

struct Thumbnail: NewThumbnail, FetchThumbnail {
    
    var image: UIImage? = UIImage(systemName: "person")
    
    func addNewThumbnail(email: String = currentUserEmail, quality: Quality = .normal) async {
        
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
    
    
    func fetchThumbnail(email: String = currentUserEmail) async throws -> (UIImage, String) {
        let db = Firestore.firestore()
        let query = db.collection(K.profilePictures)
            .whereField(K.Document.postedBy, isEqualTo: email)

        let snapshot = try await query.getDocuments()
        
        guard let imageUrlString = snapshot.documents.first?.get(K.Document.imageUrl) as? String else {
            throw ErrorTypes.noImageUrl
        }
        guard let id = snapshot.documents.first?.documentID else {
            throw ErrorTypes.noDocumentId
        }
        
        let imageURL = URL(string: imageUrlString)
        let download: ImageDownload = Download()
        let image = try await download.image(with: imageURL)
                
        return (image, id)
    }
    
}
