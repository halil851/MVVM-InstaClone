//
//  FeedCell.swift
//  InstaClone
//
//  Created by halil dikişli on 17.03.2023.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var likeCounter: UILabel!
    
    var ids = [String]()
    var index = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func getInfo(index: Int, ids: [String]) {
        self.index = index
        self.ids = ids
        
    }
    
    @IBAction func likeTap(_ sender: UIButton) {
        
        let db = Firestore.firestore()

        guard let likeCount = Int(likeCounter.text!) else {return}
        let likeManager = ["likes": likeCount + 1] as [String: Any]
        
        db.collection("Posts").document(ids[index]).setData(likeManager, merge: true)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
