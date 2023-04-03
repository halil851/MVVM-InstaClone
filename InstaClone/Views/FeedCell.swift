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
}

protocol FeedCellSegueProtocol {
    func performSegue(cellIndex: Int)
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
    
    //MARK: - Properties
    private var viewModel: FeedCellProtocol = FeedCellViewModel()
    private var ids = [String]()
    private var index = 0
    private var wholiked = [[String]]()
    var delegate: FeedCellSegueProtocol?
    
    //MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        doubleTapSetup()
        clickableLabel()
    }
    
    //MARK: - IBActions
    @IBAction private func likeTap(_ sender: UIButton? = nil) {
        
        if viewModel.isItLiked(likesList: wholiked[index]) {
            viewModel.postDislikeManager(id: ids[index])
        } else {
            viewModel.postLikeManager(id: ids[index])
        }
         
    }
    
    //MARK: - Functions
    func getInfo(index: Int, ids: [String], whoLikeIt: [[String]]) {
        self.index = index
        self.ids = ids
        self.wholiked = whoLikeIt
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
        delegate?.performSegue(cellIndex: index)
    }

    @objc private func doubleTapToLike() {
        //MARK: Heart Image, center of posted Image
        if viewModel.isItLiked(likesList: wholiked[index]){
            heartImage.image = UIImage(systemName: "heart.slash.fill")
        } else {
            heartImage.image = UIImage(systemName: "heart.fill")
        }
             
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.heartImage.alpha = 1
        }completion: { done in
            UIView.animate(withDuration: 0.4, delay: 0.2) {
                self.heartImage.alpha = 0
                
            }completion: { done in
                self.likeTap()
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
