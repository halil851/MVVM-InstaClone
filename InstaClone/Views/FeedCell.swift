//
//  FeedCell.swift
//  InstaClone
//
//  Created by halil dikişli on 17.03.2023.
//

import UIKit

class FeedCell: UITableViewCell {
    
    var viewModel: FeedCellProtocol = FeedViewModel()

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    
    var ids = [String]()
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func getInfo(index: Int, ids: [String]) {
        self.index = index
        self.ids = ids
        
    }
    
    @IBAction func likeTap(_ sender: UIButton) {

        guard let likeCount = Int(likeCounter.text!) else {return}
        let numberOfLikes = ["likes": likeCount + 1] as [String: Any]
        
        viewModel.likeManager(id: ids[index], numberOfLikes)
    }

}
