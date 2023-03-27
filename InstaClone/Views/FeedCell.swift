//
//  FeedCell.swift
//  InstaClone
//
//  Created by halil dikişli on 17.03.2023.
//

import UIKit

class FeedCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    //MARK: - Properties
    var viewModel: FeedCellProtocol = FeedViewModel()
    var ids = [String]()
    var index = 0
    var likeCounting = 0
    
    //MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        doubleTapSetup()
    }
    
    //MARK: - IBActions
    @IBAction func likeTap(_ sender: UIButton? = nil) {
//        print("likeCounting: \(likeCounting)")
        
        let numberOfLikes = ["likes": likeCounting + 1] as [String: Any]
//        print("numberoflikes: \(numberOfLikes)")
        viewModel.likeManager(id: ids[index], numberOfLikes)
    }
    
    //MARK: - Functions
    func getInfo(index: Int, ids: [String]) {
        self.index = index
        self.ids = ids
//        print("index: \(index)")

        
    }
    
    func doubleTapSetup() {
        userImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapToImage))
        tapGesture.numberOfTapsRequired = 2
        userImage.addGestureRecognizer(tapGesture)
        heartImage.alpha = 0
    }
    
    @objc func doubleTapToImage() {
        
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
}
