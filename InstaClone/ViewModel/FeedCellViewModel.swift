//
//  FeedCellViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 30.03.2023.
//

import Firebase

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
    
}
