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
    
    func getUsersPosts(with userEmail: String) async -> [UIImage]? {
        var images = [UIImage]()
        let query = db.collection(K.Posts)
            .whereField(K.Document.postedBy, isEqualTo: userEmail)
            .order(by: K.Document.date, descending: true)
        
        do {
            let snapshot = try await query.getDocuments()
            
            for document in snapshot.documents {
            
                guard let imageUrlString = document.get(K.Document.imageUrl) as? String  else {return nil}
                let imageURL = URL(string: imageUrlString)
                let image = try await ProfileViewModel.loadImage(with: imageURL)
                images.append(image)
            }
            return images
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func getProfilePicture(whose: String = currentUserEmail) async throws -> (UIImage, String) {
        let db = Firestore.firestore()
        let query = db.collection(K.profilePictures)
            .whereField(K.Document.postedBy, isEqualTo: whose)

        let snapshot = try await query.getDocuments()
        
        guard let imageUrlString = snapshot.documents.first?.get(K.Document.imageUrl) as? String else {
            throw ErrorTypes.noImageUrl
        }
        guard let id = snapshot.documents.first?.documentID else {
            throw ErrorTypes.noDocumentId
        }
        
        let imageURL = URL(string: imageUrlString)
        let image =  try await ProfileViewModel.loadImage(with: imageURL)
                
        return (image, id)
    }
   

    func isSuccesDeletingProfilePicture(id: String) async -> Bool {
        
        print("ID: \(id) is being deleted")
        //Delete fields in selected document
        do {
            try await db.collection(K.profilePictures).document(id).updateData([K.Document.imageUrl: FieldValue.delete(),
                                                                                K.Document.postedBy: FieldValue.delete()])
            print("Old Documents successfully deleted from Firebase Database")
            //Delete document ID
            try await db.collection(K.profilePictures).document(id).delete()
            print("Old Document ID successfully removed!")
            print("Ready to upload new one.")
            return true
            
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
            return false
        }
        // No need to delete the last picture from Firebase storage, because overwriten
    }
    
    static func loadImage(with url: URL?) async throws -> UIImage {
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
}
