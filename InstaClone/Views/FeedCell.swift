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
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    
    //MARK: - Properties
    var viewModel: FeedCellProtocol = FeedViewModel()
    var ids = [String]()
    var index = 0
    var likeCounting = 0
    
    //MARK: - Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: - IBActions
    @IBAction func likeTap(_ sender: UIButton) {
        
        let numberOfLikes = ["likes": likeCounting + 1] as [String: Any]
        viewModel.likeManager(id: ids[index], numberOfLikes)
    }
    
    //MARK: - Functions
    func getInfo(index: Int, ids: [String]) {
        self.index = index
        self.ids = ids
        
    }
}
