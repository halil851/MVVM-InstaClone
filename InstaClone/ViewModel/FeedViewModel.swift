//
//  FeedViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase
import FirebaseStorage
import UIKit

protocol FeedCellProtocol {
    func likeManager(id: String, _ like: [String:Any])
}

protocol FeedVCProtocol {
    var emails: [String] {get}
    var comments: [String] {get}
    var likes: [Int] {get}
    var imageURLs: [String] {get}
    var ids: [String] {get}
    func getDataFromFirestore(tableView: UITableView)
}

class FeedViewModel: FeedVCProtocol {
    let db = Firestore.firestore()
    
    var emails = [String]()
    var comments = [String]()
    var likes = [Int]()
    var imageURLs = [String]()
    var ids = [String]()
    var newLikes = [Int]()
    
    func getDataFromFirestore(tableView: UITableView) {
        let db = Firestore.firestore()
        db.collection(K.Posts)
            .order(by: K.Document.date, descending: true)
            .addSnapshotListener { snapshot, err in
                
                if err != nil {
                    print(err.debugDescription)
                    return}
                
                if snapshot?.isEmpty == false, let snapshotSafe = snapshot {
                    self.emails.removeAll()
                    self.comments.removeAll()
                    self.likes.removeAll()
                    self.imageURLs.removeAll()
                    self.ids.removeAll()
                    
                    for document in snapshotSafe.documents {
                        
                        let id = document.documentID
                        self.ids.append(id)
                        
                        if let postedBy = document.get(K.Document.postedBy) as? String {
                            self.emails.append(postedBy)
                        }
                        
                        if let comment = document.get(K.Document.postComment) as? String {
                            self.comments.append(comment)
                        }
                        
                        if let like = document.get(K.Document.likedBy) as? [String] {
                            self.likes.append(like.count)
                        }
                        
                        if let imageUrl = document.get(K.Document.imageUrl) as? String {
                            self.imageURLs.append(imageUrl)
                        }
                        
                       
                        
                    }
                        tableView.reloadData()
                }
            }
    }
}

extension FeedViewModel {
    
    func likeManager(id: String) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
                
        //Add who likes
        db.collection(K.Posts).document(id).updateData([
            K.Document.likedBy: FieldValue.arrayUnion([currentUserEmail])
        ])
        
    }
    
    
    
   
}

