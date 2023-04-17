//
//  FeedCell.swift
//  InstaClone
//
//  Created by halil dikişli on 17.03.2023.
//

import UIKit

protocol FeedCellProtocol {
    func postLikeManager(id: String)
    func postDislikeManager(id: String)
    func isItLiked(likesList: [String]) -> Bool
    func likeOrLikes(indexRow: Int, likeCount: Int) -> String
    func deletePost(id: String, storageID: String)
}

protocol FeedCellToFeedVCProtocol {
    func performSegue(cellIndex: Int, likeList: [String], likeCount: String)
    func refreshAfterActionPost()
    func showAlert(alert: UIAlertController)
    func manageUIChanges(action: Action,_ indexRow: Int)
}

class FeedCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet private weak var heartImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet private weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var optionsOutlet: UIButton!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    //MARK: - Properties
    private var viewModel: FeedCellProtocol = FeedCellViewModel()
    private var ids = [String]()
    private var storageID = [String]()
    private var index = 0
    private var wholiked = [[String]]()
    var delegate: FeedCellToFeedVCProtocol?
    private var firebaseLikeCount = Int()
    private var temporaryIntArray = [999999]
    private var lastLikeCount = 0
    private var temporaryLikedList = [String]()
    
    //MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        doubleTapSetup()
        clickableLabel()
        optionsPopUp()
    }
    
    //MARK: - IBActions
    @IBAction private func likeTap(_ sender: UIButton? = nil) {

        for i in temporaryIntArray {
            if i == index {
                firebaseLikeCount = lastLikeCount
            } else {
                firebaseLikeCount = wholiked[index].count
            }
        }
        temporaryLikedList = wholiked[index]
        likeListUIManager()
        
        if likeButtonOutlet.imageView?.image == UIImage(named: K.Images.heartRedFill) {
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartBold), for: .normal)
            likeButtonOutlet.tintColor = .label
            viewModel.postDislikeManager(id: ids[index])
            firebaseLikeCount -= 1
            delegate?.manageUIChanges(action: .NoMoreLiking, index)
            
        } else { /// like
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartRedFill), for: .normal)
            likeButtonOutlet.tintColor = .systemRed
            viewModel.postLikeManager(id: ids[index])
            firebaseLikeCount += 1
            delegate?.manageUIChanges(action: .Like, index)

            temporaryLikedList += [currentUserEmail]

        }
        lastLikeCount = firebaseLikeCount
        likeCounter.text = viewModel.likeOrLikes(indexRow: index, likeCount: lastLikeCount)
        
        temporaryIntArray.append(index)
        
        
    }
    
    
    //MARK: - Functions
    //Manage like list without Firebase to show user.
    private func likeListUIManager() {
        for user in temporaryLikedList {
            if user == currentUserEmail {
                if let deleteIndex = temporaryLikedList.firstIndex(of: user) {
                    temporaryLikedList.remove(at: deleteIndex)
                }
            }
        }
    }
    
    private func optionsPopUp() {
        //Delete Post
        let deletePost = UIAction(title: "Delete Post", image: UIImage(systemName: "trash")) { _ in
            
            let alert = UIAlertController(title: "Would you like to DELETE this post?", message: nil, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "Cancel", style: .default)
            let delete = UIAlertAction(title: "DELETE", style: .destructive) {_ in
                self.viewModel.deletePost(id: self.ids[self.index], storageID: self.storageID[self.index])
                self.delegate?.refreshAfterActionPost()
            }
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.delegate?.showAlert(alert: alert)
            
        }
        
        let menu = UIMenu( options: .displayInline, children: [ deletePost])
        optionsOutlet.menu = menu
        optionsOutlet.showsMenuAsPrimaryAction = true

    }
    
    
    
    func getInfo(index: Int, ids: [String], whoLikeIt: [[String]], storageID: [String]) {
        self.index = index
        self.ids = ids
        self.wholiked = whoLikeIt
        self.storageID = storageID
        self.temporaryLikedList = wholiked[index]
    }
    
    private func doubleTapSetup() {
        userImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToLike))
        tapGesture.numberOfTapsRequired = 2
        userImage.addGestureRecognizer(tapGesture)
        heartImage.alpha = 0
    }
    
    private func clickableLabel() {
        likeCounter.isUserInteractionEnabled = true
        let click = UITapGestureRecognizer(target: self, action: #selector(performSegue))
        likeCounter.addGestureRecognizer(click)
    }
    
    @objc private func performSegue(){
        delegate?.performSegue(cellIndex: index, likeList: temporaryLikedList, likeCount: likeCounter.text ?? "")
    }
    
    @objc private func doubleTapToLike() {
        //MARK: Heart Image, center of posted Image
        if likeButtonOutlet.imageView?.image == UIImage(named: K.Images.heartRedFill){
            heartImage.image = UIImage(systemName: "heart.slash.fill")
        } else {
            heartImage.image = UIImage(systemName: "heart.fill")
        }
        self.likeTap()
        
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.heartImage.alpha = 1
        }completion: { done in
            UIView.animate(withDuration: 0.4, delay: 0.2) {
                self.heartImage.alpha = 0
            }
        }
        
    }
    //MARK: Button Image
    func checkIfLiked(likesList: [String]) {
        if viewModel.isItLiked(likesList: likesList){
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartRedFill), for: .normal)
            likeButtonOutlet.tintColor = .systemRed
            
        } else {
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartBold), for: .normal)
            likeButtonOutlet.tintColor = .label
            
        }
    }
}
