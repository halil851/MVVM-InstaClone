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
    var date: [DateComponents] {get}
    func getDataFromFirestore(tableView: UITableView)
    func likeOrLikes(indexRow: Int) -> String
    func uploadDate(indexRow: Int) -> String
}

class FeedVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var viewModel: FeedVCProtocol = FeedViewModel()
    var lastTabBarIndex = 0
    var refreshControl = UIRefreshControl()

    
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
        // Refresh Check
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
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
        cell.dateLabel.text = viewModel.uploadDate(indexRow: indexPath.row)
        cell.userEmailLabel.text = viewModel.emails[indexPath.row]
        cell.commentLabel.attributedText = boldAndRegularText(indexRow: indexPath.row)
        cell.likeCounter.text = viewModel.likeOrLikes(indexRow: indexPath.row)
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
            viewModel.getDataFromFirestore(tableView: tableView)
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
            destinationVC.numberOfLikesStr = viewModel.likeOrLikes(indexRow: index)
                
        }
    }
    
}

extension FeedVC: UIScrollViewDelegate {
    // Aşağı kaydırma işlemi gerçekleştiğinde tetiklenecek metod
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height {
            // TableView aşağı kaydırıldı ve en altına geldi
            refreshTableView()
        }
    }
    
    // Yenileme işlemi gerçekleştiğinde tetiklenecek metod
    @objc func refreshTableView() {
        // Yenileme işlemi yapılır
        viewModel.getDataFromFirestore(tableView: tableView)

        // Refresh kontrolü durdurulur
        refreshControl.endRefreshing()
    }
}

/*
 
 import UIKit

 class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

     @IBOutlet weak var tableView: UITableView!
     var refreshControl = UIRefreshControl()

     override func viewDidLoad() {
         super.viewDidLoad()

         // TableView'in özellikleri ayarlanır
         tableView.dataSource = self
         tableView.delegate = self

         // Refresh kontrolü oluşturulur ve TableView'e eklenir
         refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
         tableView.addSubview(refreshControl)
     }

     // Aşağı kaydırma işlemi gerçekleştiğinde tetiklenecek metod
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let offsetY = scrollView.contentOffset.y
         let contentHeight = scrollView.contentSize.height

         if offsetY > contentHeight - scrollView.frame.height {
             // TableView aşağı kaydırıldı ve en altına geldi
             refreshTableView()
         }
     }

     // Yenileme işlemi gerçekleştiğinde tetiklenecek metod
     @objc func refreshTableView() {
         // Yenileme işlemi yapılır
         // Örneğin, TableView'de gösterilen veriler yenilenir
         tableView.reloadData()

         // Refresh kontrolü durdurulur
         refreshControl.endRefreshing()
     }

     // TableView'in diğer metodları (numberOfRowsInSection, cellForRowAt vb.)
     // burada yer alacak
 }

 */
