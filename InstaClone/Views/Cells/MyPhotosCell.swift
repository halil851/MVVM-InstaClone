//
//  MyPhotosCell.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

protocol MyPhotosCellToProfileVCProtocol: AnyObject {
    func performSegue()
}

class MyPhotosCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    weak var delegate: MyPhotosCellToProfileVCProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setImageInteractable()
    }
    
    func setImageInteractable() {
        image.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(tapPhoto))
        image.addGestureRecognizer(imageTap)
   }
    
    @objc private func tapPhoto() {
        delegate?.performSegue()
    }
    
    

}
