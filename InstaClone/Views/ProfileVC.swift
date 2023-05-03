//
//  ProfileVC.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

class ProfileVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    let viewModel = ProfileViewModel()
    var images = [UIImage]()
  
    //MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nibCell = UINib(nibName: K.MyPhotosCell, bundle: nil)
        collectionView.register(nibCell, forCellWithReuseIdentifier: K.MyPhotosCell)
          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        images.removeAll()
        viewModel.getCurrentUsersPosts(with: currentUserEmail, completion: { image, isReadyToReload  in
            self.images.append(image)
            
            if isReadyToReload { self.collectionView.reloadData() }

        })
        
    }
    //MARK: - IBActions
    
    
    
    //MARK: - Functions

    
   


}

//MARK: - Collectionview Operations
extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    
    
    //MARK: - Header Configurations
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: K.HeaderView, for: indexPath) as? MyPhotosHeaderView else {
            return UICollectionReusableView()
        }
        view.delegate = self
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2) // Height of header
    }
    
    
}



//MARK: - Header View Protocol
extension ProfileVC: HeaderViewToProfileVCProtocol {
    func pickerPresent(picker: UIImagePickerController) {
        present(picker, animated: true)
    }
}
