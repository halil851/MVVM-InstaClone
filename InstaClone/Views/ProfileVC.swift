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
        
        viewModel.getCurrentUsersPosts(completion: { image in
            self.images.append(image)
            self.collectionView.reloadData()
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
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // İç boşluğu ayarla
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0.0
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0.0
       }
    
    
    
    //MARK: - Header Configurations
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: K.HeaderView, for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2) // Height of header
    }
    
    
}
