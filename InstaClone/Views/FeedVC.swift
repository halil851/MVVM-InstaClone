//
//  FeedVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import SDWebImage

protocol FeedVCProtocol {
    var emails: [String] {get}
    var comments: [String] {get}
    var likes: [Int] {get}
    var imageURLs: [String] {get}
    var ids: [String] {get}
    var whoLiked: [[String]] {get}
    func getDataFromFirestore(tableView: UITableView)
}

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
        tableView.separatorStyle = .none
    }
    
    func boldAndRegularText(indexRow: Int) -> NSMutableAttributedString{
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15.0)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)]
        let boldText = NSAttributedString(string: viewModel.emails[indexRow], attributes: boldAttribute)
        let regularText = NSAttributedString(string:" \(viewModel.comments[indexRow])", attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        return newString
    }
    
    func likeOrLikes(indexRow: Int) -> String {

        let likesCount = viewModel.likes[indexRow]
        if likesCount > 1 {
            return "\(likesCount) likes"
        }
        return "\(likesCount) like"
        
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
        cell.delegate = self
        cell.userEmailLabel.text = viewModel.emails[indexPath.row]
        cell.commentLabel.attributedText = boldAndRegularText(indexRow: indexPath.row)
        cell.likeCounter.text = likeOrLikes(indexRow: indexPath.row)
        cell.userImage.sd_setImage(with: URL(string: viewModel.imageURLs[indexPath.row]))
        cell.checkIfLiked(likesList: viewModel.whoLiked[indexPath.row])
        cell.getInfo(index: indexPath.row,
                     ids: viewModel.ids,
                     whoLikeIt: viewModel.whoLiked)
        
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

extension FeedVC: FeedCellSegueProtocol {
    func performSegue(cellIndex: Int) {
        performSegue(withIdentifier: "likeList", sender: cellIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = sender as? Int else {return}
        
        if segue.identifier == "likeList",
           let destinationVC = segue.destination as? LikeListVC{
            
            destinationVC.likedUser = viewModel.whoLiked[index]
            destinationVC.numberOfLikesStr = likeOrLikes(indexRow: index)
                
        }
    }
    
}
