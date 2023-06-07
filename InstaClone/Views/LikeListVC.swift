//
//  LikeListVC.swift
//  InstaClone
//
//  Created by halil dikişli on 29.03.2023.
//

import UIKit

class LikeListVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var numberOfLikes: UILabel!
    
    var likedUser = [String]()
    var numberOfLikesStr = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        numberOfLikes.text = numberOfLikesStr
    }

}

extension LikeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if likedUser.count == 0 { return 1 }
        return likedUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if likedUser.count == 0 {
            cell.textLabel?.text = "No one liked this post"
            return cell
        }
        cell.textLabel?.text = likedUser[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
