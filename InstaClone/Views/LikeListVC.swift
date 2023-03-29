//
//  LikeListVC.swift
//  InstaClone
//
//  Created by halil dikişli on 29.03.2023.
//

import UIKit

class LikeListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var likedUser = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

}

extension LikeListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if likedUser.count == 0 {
            return 1
        }
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
    
    
}
