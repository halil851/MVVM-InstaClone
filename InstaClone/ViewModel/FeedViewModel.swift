//
//  FeedViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase
//import UIKit

class FeedViewModel: FeedVCProtocol {
    private let db = Firestore.firestore()
    
    var emails = [String]()
    var comments = [String]()
    var likes = [Int]()
    var imageURLs = [String]()
    var ids = [String]()
    var whoLiked = [[String]]()
    var date = [DateComponents]()
    
    
    func getDataFromFirestore(tableView: UITableView) {
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
                    self.whoLiked.removeAll()
                    self.date.removeAll()
                    
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
                            self.whoLiked.append(like)
                            
                        }
                        
                        if let imageUrl = document.get(K.Document.imageUrl) as? String {
                            self.imageURLs.append(imageUrl)
                        }
                        
                        if let date = document.get(K.Document.date) as? Timestamp {
                            
                            let uploadDate = Date(timeIntervalSince1970: TimeInterval(date.seconds))
                            let now = Date()
                            // Calculation the time between 2 dates
                            let calendar = Calendar.current
                            let timeDifference = calendar.dateComponents([ .year,.weekOfMonth, .month, .day, .hour, .minute], from: uploadDate, to: now)
                            self.date.append(timeDifference)
                        }
                        
                    }
                    tableView.reloadData()
                }
            }
    }
}

extension FeedViewModel {
    func likeOrLikes(indexRow: Int) -> String {

        let likesCount = likes[indexRow]
        if likesCount > 1 {
            return "\(likesCount) likes"
        }
        return "\(likesCount) like"
        
    }
    
    func uploadDate(indexRow: Int) -> String {
        guard let year = date[indexRow].year else {return ""}
        if year > 0 {
            return singularPluralDate(date: year, "year")
        }
        
        guard let month = date[indexRow].month else {return ""}
        if month > 0 {
            return singularPluralDate(date: month, "month")
        }
        
        guard let week = date[indexRow].weekOfMonth else {return ""}
        if week > 0 {
            return singularPluralDate(date: week, "week")
        }
        
        guard let day = date[indexRow].day else {return ""}
        if day > 0 {
            return singularPluralDate(date: day, "day")
        }
        
        guard let hour = date[indexRow].hour else {return ""}
        if hour > 0 {
            return singularPluralDate(date: hour, "hour")
        }
        
        guard let minute = date[indexRow].minute else {return ""}
        if minute == 0 {
            return "now"
        }
        return singularPluralDate(date: minute, "min")
    }
    
    func singularPluralDate(date: Int, _ str: String) -> String{
        if date == 1 {
            return "\(date) \(str) ago"
        }
        return "\(date) \(str)s ago"
    }
}



