//
//  ReusableHeader.swift
//  InstaClone
//
//  Created by halil dikişli on 2.05.2023.
//

import UIKit

class ReusableView: UIView, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profilePictureWidthRatio: NSLayoutConstraint!
    
    let nibName = "ReusableView"
    
    weak var delegate: ReusableViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override func awakeFromNib() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenWeight = windowScene.screen.bounds.size.width
        let profilePictureWidth = screenWeight * profilePictureWidthRatio.multiplier
        profilePicture.layer.cornerRadius = profilePictureWidth / 2
    }
    
     func setImageInteractable() {
        profilePicture.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        profilePicture.addGestureRecognizer(imageTap)
    }
    
    @objc private func selectProfilePicture() {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        delegate?.pickerPresent(picker: picker)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Selected item is not an image")
            return
        }

        Task {
           await delegate?.addNewProfilePicture(image: image)
        }
            
        
        picker.dismiss(animated: true)
        
    }
    
}

