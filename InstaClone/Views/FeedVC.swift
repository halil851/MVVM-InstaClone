//
//  FeedVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage


class FeedVC: UIViewController {
    
    var emails = [String]()
    var comments = [String]()
    var likes = [Int]()
    var imageURLs = [String]()
    
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = (view.window?.windowScene?.screen.bounds.height ?? 800) / 1.75
        getDataFromFirestore()
    }
    

}

//MARK: - Firebase Operations
extension FeedVC {
    
    func getDataFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("Posts").addSnapshotListener { snapshot, err in
            if err != nil {
                print(err.debugDescription)
            } else {
                if snapshot?.isEmpty != true, let snapshotSafe = snapshot {
                    
                    for document in snapshotSafe.documents {
//                        let id = document.documentID
                        
                        if let postedBy = document.get("postedBy") as? String {
                            self.emails.append(postedBy)
                        }
                        
                        if let comment = document.get("postComment") as? String {
                            self.comments.append(comment)
                        }
                        
                        if let like = document.get("likes") as? Int {
                            self.likes.append(like)
                        }
                        
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.imageURLs.append(imageUrl)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
                
                
            }
        }
        
        
        
    }
    
}

//MARK: - Tableview Operations
extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        cell.userEmailLabel.text = emails[indexPath.row]
        cell.commentLabel.text = comments[indexPath.row]
        cell.likeCounter.text = String(likes[indexPath.row])
        cell.userImage.sd_setImage(with: URL(string: imageURLs[indexPath.row]))
        
        
        
        return cell
    }
    
    
}
