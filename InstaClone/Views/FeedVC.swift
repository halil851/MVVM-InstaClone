//
//  FeedVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit

protocol FeedVCtoProfilVCProtocol: AnyObject {
    func reloadAfterDismissModalPresentation()
}

protocol FeedVCProtocol {
    var emails: [String] {get set}
    var comments: [String] {get set}
    var images: [UIImage] {get set}
    var imagesHeights: [CGFloat] {get set}
    var ids: [String] {get set}
    var storageID: [String] {get set}
    var whoLiked: [[String]] {get set}
    var date: [DateComponents] {get set}
    var isPaginating: Bool {get}
    func getDataFromFirestore(_ tableView: UITableView, limit: Int?, pagination: Bool, getNewOnes: Bool, whosePost: String?) async
    func fetchThumbnail(userMail: String)
    func likeOrLikes(indexRow: Int) -> String
    func uploadDate(indexRow: Int) -> String
    func isOptionsButtonHidden(user: String) -> Bool
    var profilePictureSDictionary: [String:UIImage] {get}
}

extension FeedVCProtocol {
    func getDataFromFirestore (_ tableView: UITableView, limit: Int? = nil, pagination: Bool = false, getNewOnes: Bool = false, whosePost: String? = nil) async{
       await getDataFromFirestore(tableView, limit: limit, pagination: pagination, getNewOnes: getNewOnes, whosePost: whosePost)
    }
}

class FeedVC: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    
    //MARK: - Properties
    var viewModel: FeedVCProtocol = FeedViewModel()
    private var lastTabBarIndex = 0
    private var refreshControl = UIRefreshControl()
    private var isScrollingToBottom = false
    var visitedUser: String? = nil
    var isProfilVisiting = false
    
    weak var delegate: FeedVCtoProfilVCProtocol?
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        Task{
            await viewModel.getDataFromFirestore(tableView, pagination: true, getNewOnes: true, whosePost: visitedUser)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        dismissButton.isHidden = true
        if isProfilVisiting { dismissButton.isHidden = false }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        dismissButton.isHidden = true
        if isProfilVisiting { delegate?.reloadAfterDismissModalPresentation() }
        
    }
    
    
    //MARK: - IBActions
    @IBAction func dismissTap(_ sender: UIButton) {
        dismiss(animated: true)
        visitedUser = nil
        isProfilVisiting = false
        delegate?.reloadAfterDismissModalPresentation()
    }
    
    
    //MARK: - Functions
    private func initialSetup() {
        if visitedUser != nil {isProfilVisiting = true }
        tabBarController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        // Enable Refresh Check
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
        //Nib register
        tableView.register(UINib(nibName: K.FeedCell , bundle: nil), forCellReuseIdentifier: K.Cell )
        
    }
    
    private func boldAndRegularText(indexRow: Int) -> NSMutableAttributedString{
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15.0)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)]
        let boldText = NSAttributedString(string: viewModel.emails[indexRow], attributes: boldAttribute)
        let regularText = NSAttributedString(string:" \(viewModel.comments[indexRow])", attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        return newString
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    //MARK: - Refresh Control
    // Get data and stop refreshing
     @objc func refreshTableView() {
         guard !isProfilVisiting else {
             self.refreshControl.endRefreshing()
             return}
         
         self.tableView.setContentOffset(CGPointZero, animated: true)
         
         Task{ // Without Task {} You get Error
             // Refresh Data
             await viewModel.getDataFromFirestore(tableView, limit: 5, pagination: false, getNewOnes: true, whosePost: visitedUser)
             
             DispatchQueue.main.async {
                 self.refreshControl.endRefreshing()
             }
             
         }
    }
    
}

//MARK: - Tableview Operations
extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("post count: \(viewModel.images.count)")
        return viewModel.images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell, for: indexPath) as? FeedCell,
              viewModel.emails.isEmpty == false else {
            return UITableViewCell()
        }
        
        let email = viewModel.emails[indexPath.row]
        cell.delegate = self
        cell.userImage.image = viewModel.images[indexPath.row]
        cell.imageHeight.constant = viewModel.imagesHeights[indexPath.row]
        cell.userEmailLabel.text = email
        cell.commentLabel.attributedText = boldAndRegularText(indexRow: indexPath.row)
        cell.likeCounter.text = viewModel.likeOrLikes(indexRow: indexPath.row)
        cell.checkIfLiked(likesList: viewModel.whoLiked[indexPath.row])
        cell.getInfo(indexPath: indexPath,
                     ids: viewModel.ids,
                     whoLikeIt: viewModel.whoLiked,
                     storageID: viewModel.storageID,
                     demoEmail: visitedUser)
        
        cell.dateLabel.text = viewModel.uploadDate(indexRow: indexPath.row)
        cell.smallProfilePicture.image = viewModel.profilePictureSDictionary[email]
        if isProfilVisiting {cell.optionsOutlet.isHidden = viewModel.isOptionsButtonHidden(user: email)}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard viewModel.comments.isEmpty == false,
              viewModel.emails.isEmpty == false else {
            print("comments and emails are empty")
            return 700
        }
        
        let charNumber = viewModel.comments[indexPath.row].count + viewModel.emails[indexPath.row].count
        let coefficient = Double(charNumber) / Double(45) //45 is allowed char number of a row
        let height: Double = Double(coefficient * 20)  // 20 is a row height
        return viewModel.imagesHeights[indexPath.row] + 145 + CGFloat(height)
    }
    
}

//MARK: - Tab Bar Operations
extension FeedVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Go to top with animation if user at Feed and top Feed
        if lastTabBarIndex == 0, tabBarController.selectedIndex == 0 {
            DispatchQueue.main.async {
                self.tableView.setContentOffset(CGPointZero, animated: true)
            }
        }
        
        if tabBarController.selectedIndex == 0 {
            visitedUser = nil
            isProfilVisiting = false
            FeedViewModel.indexPath = nil
            dismissButton.isHidden = true
        }
        lastTabBarIndex = tabBarController.selectedIndex
    }
}

//MARK: - FeedCellToFeedVCProtocol
extension FeedVC: FeedCellToFeedVCProtocol {
    
    func deleteAIndex(indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.first?.row else {return}
        
        viewModel.comments.remove(at: indexPath)
        viewModel.date.remove(at: indexPath)
        viewModel.emails.remove(at: indexPath)
        viewModel.ids.remove(at: indexPath)
        viewModel.images.remove(at: indexPath)
        viewModel.storageID.remove(at: indexPath)
        viewModel.whoLiked.remove(at: indexPath)
        viewModel.imagesHeights.remove(at: indexPath)
                
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .left) //Animate to left when deleting
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    func manageUIChanges(action: Action,_ indexRow: Int) {
        
        if action == .NoMoreLiking {
            for user in viewModel.whoLiked[indexRow] {
                if user == currentUserEmail {
                    viewModel.whoLiked[indexRow].removeAll(where: {$0 == currentUserEmail})
                }
            }
        } else {
            viewModel.whoLiked[indexRow].append(currentUserEmail)
            
        }
    }
    
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    func performSegue(cellIndex: Int, likeList: [String], likeCount: String) {
        let sendList: [Any] = [likeList, likeCount]
        performSegue(withIdentifier: "likeList", sender: sendList)
    }
    
    func goToVisitProfile(with userEmail: String?, indexRow: Int) {
        guard let userEmail = userEmail else {return}
        guard let image = viewModel.profilePictureSDictionary[viewModel.emails[indexRow]] else {return}
        lastTabBarIndex = 3
        if userEmail == currentUserEmail {
            tabBarController?.selectedIndex = 3
        } else {
            let sendList: [Any] = [userEmail, image]
            performSegue(withIdentifier: "visitProfile", sender: sendList)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "visitProfile",
           let destinationVC = segue.destination as? ProfileVC,
           let object = sender as? [Any],
           let email = object[0] as? String{
            
            destinationVC.email = email
            destinationVC.image = object[1] as? UIImage
            return
        }
        
        guard let object = sender as? [Any] else {return}
        guard let likeList = object[0] as? [String] else {return}
        guard let likeCount = object[1] as? String else {return}
        
        if segue.identifier == "likeList",
           let destinationVC = segue.destination as? LikeListVC{
            
            destinationVC.likedUser = likeList
            destinationVC.numberOfLikesStr = likeCount
        }
    }
}

//MARK: - ScrollView Operations
extension FeedVC: UIScrollViewDelegate {
    // Trigger when scroll down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard viewModel.emails.count > 0 else {return} // Means there is no post on the screen yet. So avoid Scrolling Down.
        guard !viewModel.isPaginating else {return} //

        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 150 - scrollView.frame.size.height) {

            guard !isScrollingToBottom else {return}
            isScrollingToBottom = true

            self.tableView.tableFooterView = self.createSpinnerFooter()
            Task {
                await self.viewModel.getDataFromFirestore(self.tableView, limit: 4, pagination: true, whosePost: visitedUser)

                DispatchQueue.global().asyncAfter(deadline: .now()+2, execute: {
                    DispatchQueue.main.async { [self] in

                        tableView.tableFooterView = nil
                    }
                })
                isScrollingToBottom = false
            }
        }
    }
}
