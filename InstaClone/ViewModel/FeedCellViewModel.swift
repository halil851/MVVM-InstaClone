//
//  FeedCellViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 30.03.2023.
//

import Firebase
import FirebaseStorage

struct FeedCellViewModel: FeedCellProtocol {
    let db = Firestore.firestore()
    
    func postLikeManager(id: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        
        //Add who likes
        db.collection(K.Posts).document(id).updateData([
            K.Document.likedBy: FieldValue.arrayUnion([currentUserEmail])
        ])
        
    }
    
    func postDislikeManager(id: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        
        //Remove who no longer like
        db.collection(K.Posts).document(id).updateData([
            K.Document.likedBy: FieldValue.arrayRemove([currentUserEmail])
        ])
        
    }
    
    func isItLiked(likesList: [String]) -> Bool {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return false}
        
        for user in likesList{
            if user == currentUserEmail{
                return true
            }
        }
        return false
    }
    
    func likeOrLikes(indexRow: Int, likeCount: Int) -> String {
        if likeCount > 1 {
            return "\(likeCount) likes"
        }
        return "\(likeCount) like"
    }
    
    func deletePost(id: String, storageID: String) {
        
        //Delete fields in selected document
        db.collection(K.Posts).document(id).updateData([K.Document.imageUrl: FieldValue.delete(),
                                                        K.Document.postedBy: FieldValue.delete(),
                                                        K.Document.postComment: FieldValue.delete(),
                                                        K.Document.date: FieldValue.delete(),
                                                        K.Document.likedBy: FieldValue.delete(),
                                                        K.Document.storageID: FieldValue.delete(),]) { err in     
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        //Delete document ID
        db.collection(K.Posts).document(id).delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }

        }
        
        //Delete photo from Firebase storage
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        // Create a reference to the file to delete
        let photoPath = storageRef.child(K.media).child(storageID)
        // Delete the file
        photoPath.delete { error in
          if let error = error {
              print(error.localizedDescription)
          } else {
              print("File deleted successfully from Firebase Storage")
          }
        }
        
    }
    
}
