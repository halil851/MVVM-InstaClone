//
//  FeedCell.swift
//  InstaClone
//
//  Created by halil dikişli on 17.03.2023.
//

import UIKit

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
    private var viewModel = FeedCellViewModel()
    private var info = GetInfoModel(indexPath: IndexPath(), id: "", whoLiked: [""], storageID: "")
    private var firebaseLikeCount = Int()
    private var temporaryIntArray = [999999]
    private var lastLikeCount = 0
    private var UILikedList = [String]()
    var delegate: FeedCellToFeedVCDelegate?
   
    //MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        setups()
        smallProfilePicture.layer.cornerRadius = smallProfilePicture.frame.size.width / 2
    }
    
    //MARK: - IBActions
    @IBAction private func likeTap(_ sender: UIButton? = nil) {
        for i in temporaryIntArray {
            if i == info.indexPath.row {
                firebaseLikeCount = lastLikeCount
            } else {
                firebaseLikeCount = info.whoLiked.count
            }
        }
        
        UILikedList = info.whoLiked
        likeListUIManager()
        
        if likeButtonOutlet.imageView?.image == UIImage(named: K.Images.heartRedFill) {
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartBold), for: .normal)
            likeButtonOutlet.tintColor = .label
            viewModel.postDislikeManager(id: info.id)
            firebaseLikeCount -= 1
            delegate?.manageUIChanges(action: .noMoreLiking, info.indexPath.row)
            
        } else { /// like
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartRedFill), for: .normal)
            likeButtonOutlet.tintColor = .systemRed
            viewModel.postLikeManager(id: info.id)
            firebaseLikeCount += 1
            delegate?.manageUIChanges(action: .like, info.indexPath.row)

            UILikedList += [currentUserEmail]

        }
        lastLikeCount = firebaseLikeCount
        likeCounter.text = viewModel.likeOrLikes(indexRow: info.indexPath.row, likeCount: lastLikeCount)
        
        temporaryIntArray.append(info.indexPath.row)
    }
    
    
    //MARK: - Functions
    
    private func setups() {
        clickableLikeCounterLabelSetup()
        doubleTapSetup()
        optionsPopUp()
        pinchToZoomSetup()
    }
    
    func getInfo(information: GetInfoModel, visitor: String?) {
        info = information
        self.UILikedList = info.whoLiked
        if visitor == nil { clickableUserEmailLabelActivation() }
    }
    
    //Manage like list without Firebase to show user.
    private func likeListUIManager() {
        for user in UILikedList {
            if user == currentUserEmail {
                if let deleteIndex = UILikedList.firstIndex(of: user) {
                    UILikedList.remove(at: deleteIndex)
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

                self.viewModel.deletePost(id: self.info.id, storageID: self.info.storageID)
                Task{
                    await self.delegate?.deleteAnIndex(indexPaths: [self.info.indexPath])
                }
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
    
    private func clickableLikeCounterLabelSetup() {
        likeCounter.isUserInteractionEnabled = true
        let clickLikeCounter = UITapGestureRecognizer(target: self, action: #selector(performSegue))
        likeCounter.addGestureRecognizer(clickLikeCounter)
    }
    private func clickableUserEmailLabelActivation() {
        userEmailLabel.isUserInteractionEnabled = true
        let clickUserEmailLabel = UITapGestureRecognizer(target: self, action: #selector(visitProfilePage))
        userEmailLabel.addGestureRecognizer(clickUserEmailLabel)
    }
    
    @objc private func visitProfilePage() {
        delegate?.goToVisitProfile(with: userEmailLabel.text, indexRow: info.indexPath.row)
    }
    
    @objc private func performSegue(){
        delegate?.performSegue(cellIndex: info.indexPath.row, likeList: UILikedList, likeCount: likeCounter.text ?? "")
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
        }completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.2) {
                self.heartImage.alpha = 0
            }
        }
        
    }
    
    //MARK: Button Image
    func checkIfLiked(likesList: [String]) {
        if viewModel.isLiked(likesList: likesList){
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartRedFill), for: .normal)
            likeButtonOutlet.tintColor = .systemRed
            
        } else {
            likeButtonOutlet.setImage(UIImage(named: K.Images.heartBold), for: .normal)
            likeButtonOutlet.tintColor = .label
            
        }
    }
}
