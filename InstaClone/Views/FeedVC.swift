//
//  FeedVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import SDWebImage

class FeedVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var viewModel: FeedVCProtocol = FeedViewModel()
    var lastTabBarIndex = 0
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        viewModel.getDataFromFirestore(tableView: tableView)
    }
    
    //MARK: - IBActions
    
    
    //MARK: - Functions
    func initialSetup() {
        tabBarController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = (view.window?.windowScene?.screen.bounds.height ?? 800) / 1.5
    }
}

//MARK: - Tableview Operations
extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.emails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        cell.userEmailLabel.text = viewModel.emails[indexPath.row]
        cell.commentLabel.text = viewModel.comments[indexPath.row]
        
        let likesCount = viewModel.likes[indexPath.row]
        cell.likeCounting = likesCount
        if likesCount > 1 {
            cell.likeCounter.text = "\(cell.likeCounting) likes"
        } else {
            cell.likeCounter.text = "\(cell.likeCounting) like"
        }
        
        
        cell.userImage.sd_setImage(with: URL(string: viewModel.imageURLs[indexPath.row] ))
        cell.getInfo(index: indexPath.row, ids: viewModel.ids)
        
        return cell
    }
    
}

//MARK: - Tab Bar Operations
extension FeedVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Go to top with animation if user at Feed
        if lastTabBarIndex == 0, tabBarController.selectedIndex == 0 {
            tableView.setContentOffset(CGPointZero, animated: true)
        }
        lastTabBarIndex = tabBarController.selectedIndex
    }
}
