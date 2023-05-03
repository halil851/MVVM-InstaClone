//
//  VisitProfile.swift
//  InstaClone
//
//  Created by halil dikişli on 2.05.2023.
//

import UIKit

class VisitProfileVC: UIViewController {
    
    @IBOutlet weak var reusableView: ReusableView!
    var images = [UIImage]()
    var email = String()
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reusableView.collectionView.dataSource = self
        reusableView.collectionView.delegate = self
        
        let nibCell = UINib(nibName: K.MyPhotosCell, bundle: nil)
        reusableView.collectionView.register(nibCell, forCellWithReuseIdentifier: K.MyPhotosCell)
        
        navigationItem.title = email
        reusableView.userEmail.text = email
        reusableView.profilePicture.image = image
        
        let profileVM = ProfileViewModel()
        profileVM.getCurrentUsersPosts(with: email) { [self] image, isReadyToReload in
            self.images.append(image)
            if isReadyToReload {
                calculateCollectionViewHeight(with: images.count)
                self.reusableView.collectionView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backItem?.title = ""
    }
    
    private func calculateCollectionViewHeight(with imageCount: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenHeight = windowScene.screen.bounds.size.height
        let headerViewHeight = screenHeight * reusableView.headerViewHeight.multiplier
        let collectionViewCellHeight = reusableView.collectionView.frame.width/3
        let howManyRows = CGFloat(imageCount / 3) + 1
        let collectionViewHeight = howManyRows * collectionViewCellHeight
        reusableView.viewHeight.constant = headerViewHeight + collectionViewHeight - screenHeight
    }
   

}
//MARK: - Collectionview Operations
extension VisitProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.MyPhotosCell, for: indexPath) as? MyPhotosCell else {
            return UICollectionViewCell()
        }
        cell.image.image = images[indexPath.row]
        
        return cell
    }
    
    //MARK: - Cell Sizes and Edges
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 2.0, height: collectionView.frame.width/3)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}

//MARK: - Header View Protocol
extension VisitProfileVC: HeaderViewToProfileVCProtocol {
    func pickerPresent(picker: UIImagePickerController) {
        present(picker, animated: true)
    }
}
