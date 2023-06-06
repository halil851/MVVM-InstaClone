//
//  MyPhotosCell.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

class MyPhotosCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    weak var delegate: MyPhotosCellToProfileVCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    @objc private func tapPhoto() {
        delegate?.performSegue()
    }
    
    

}
