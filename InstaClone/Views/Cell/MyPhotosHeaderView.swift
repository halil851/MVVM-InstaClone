//
//  HeaderView.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

class MyPhotosHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.text = currentUserEmail
        
    }
}
