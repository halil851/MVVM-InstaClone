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
    func deleteAIndex(indexPaths: [IndexPath])
    func goToVisitProfile()
}

class FeedCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var smallProfilePicture: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet private weak var heartImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet private weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var optionsOutlet: UIButton!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var buttons: UIStackView!
    
    //MARK: - Properties
    private var viewModel: FeedCellProtocol = FeedCellViewModel()
    private var ids = [String]()
    private var storageID = [String]()
    private var indexPath = IndexPath()
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
        pinchToZoomSetup()
        // Make ImageView Circle
        smallProfilePicture.layer.cornerRadius = smallProfilePicture.frame.size.width / 2
        smallProfilePicture.clipsToBounds = true
    }
    
    //MARK: - IBActions
    @IBAction private func likeTap(_ sender: UIButton? = nil) {

        for i in temporaryIntArray {
            if i == indexPath.row {
                firebaseLikeCount = lastLikeCount
            } else {
                firebaseLikeCount = wholiked[indexPath.row].count
            }
        }
        temporaryLikedList = wholiked[indexPath.row]
        likeListUIManager()
        
        if likeButtonOutlet.imageView?.image == UIImage(named: K.Images.heartRedFill) {
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartBold), for: .normal)
            likeButtonOutlet.tintColor = .label
            viewModel.postDislikeManager(id: ids[indexPath.row])
            firebaseLikeCount -= 1
            delegate?.manageUIChanges(action: .NoMoreLiking, indexPath.row)
            
        } else { /// like
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartRedFill), for: .normal)
            likeButtonOutlet.tintColor = .systemRed
            viewModel.postLikeManager(id: ids[indexPath.row])
            firebaseLikeCount += 1
            delegate?.manageUIChanges(action: .Like, indexPath.row)

            temporaryLikedList += [currentUserEmail]

        }
        lastLikeCount = firebaseLikeCount
        likeCounter.text = viewModel.likeOrLikes(indexRow: indexPath.row, likeCount: lastLikeCount)
        
        temporaryIntArray.append(indexPath.row)
        
        
    }
    
    
    //MARK: - Functions
    func getInfo(indexPath: IndexPath, ids: [String], whoLikeIt: [[String]], storageID: [String]) {
        self.indexPath = indexPath
        self.ids = ids
        self.wholiked = whoLikeIt
        self.storageID = storageID
        self.temporaryLikedList = wholiked[indexPath.row]
    }
    
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
    
    //MARK: - Setups
    private func doubleTapSetup() {
        userImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToLike))
        tapGesture.numberOfTapsRequired = 2
        userImage.addGestureRecognizer(tapGesture)
        heartImage.alpha = 0
    }
    
    private func pinchToZoomSetup(){
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(_:)))
        userImage.addGestureRecognizer(pinchGesture)
        userImage.isUserInteractionEnabled = true
    }
    
    
    private func optionsPopUp() {
        //Delete Post
        let deletePost = UIAction(title: "Delete Post", image: UIImage(systemName: "trash")) { _ in
            
            let alert = UIAlertController(title: "Would you like to DELETE this post?", message: nil, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "Cancel", style: .default)
            let delete = UIAlertAction(title: "DELETE", style: .destructive) {_ in
                self.viewModel.deletePost(id: self.ids[self.indexPath.row], storageID: self.storageID[self.indexPath.row])
                self.delegate?.deleteAIndex(indexPaths: [self.indexPath])
            }
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.delegate?.showAlert(alert: alert)
            
        }
        
        let menu = UIMenu( options: .displayInline, children: [ deletePost])
        optionsOutlet.menu = menu
        optionsOutlet.showsMenuAsPrimaryAction = true

    }
    
    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else {return}
        var duration: TimeInterval = 0.3
        let touch = sender.location(in: userImage)
        let scale = sender.scale
        
        
        switch sender.state {
        case .began, .changed:
            startAndStopZooming(hideItems: true)
            let pinchCenter = CGPoint(x: touch.x - userImage.bounds.midX,
                                      y: touch.y - userImage.bounds.midY)
            let transform = userImage.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            userImage.transform = transform
            sender.scale = 1
            
    
        case .ended, .cancelled, .failed:
            startAndStopZooming(hideItems: false)
            UIView.animate(withDuration: duration, animations: {
                
                self.userImage.transform = .identity
            })
       
        case .possible:
            print(".possible")
        @unknown default:
            break
        }
        
        func startAndStopZooming(hideItems: Bool) {

            if hideItems{ duration = 0.1 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.1, execute: {
                self.userEmailLabel.isHidden = hideItems
                self.likeCounter.isHidden = hideItems
                self.commentLabel.isHidden = hideItems
                self.dateLabel.isHidden = hideItems
                self.buttons.isHidden = hideItems
                self.smallProfilePicture.isHidden = hideItems
                
                if self.userEmailLabel.text == currentUserEmail {
                    self.optionsOutlet.isHidden = hideItems
                }
            })
            
            
        }
       
        
            
    }
    
    private func clickableLabel() {
        likeCounter.isUserInteractionEnabled = true
        let clickLikeCounter = UITapGestureRecognizer(target: self, action: #selector(performSegue))
        likeCounter.addGestureRecognizer(clickLikeCounter)
        
        userEmailLabel.isUserInteractionEnabled = true
        let clickUserEmailLabel = UITapGestureRecognizer(target: self, action: #selector(visitProfilePage))
        userEmailLabel.addGestureRecognizer(clickUserEmailLabel)
    }
    
    @objc private func visitProfilePage() {
        delegate?.goToVisitProfile()
    }
    
    @objc private func performSegue(){
        delegate?.performSegue(cellIndex: indexPath.row, likeList: temporaryLikedList, likeCount: likeCounter.text ?? "")
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
