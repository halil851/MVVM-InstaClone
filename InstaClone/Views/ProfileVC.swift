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

  
    //MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nibCell = UINib(nibName: K.MyPhotosCell, bundle: nil)
        collectionView.register(nibCell, forCellWithReuseIdentifier: K.MyPhotosCell)
        
    }
    //MARK: - IBActions
    
    
    
    //MARK: - Functions

    
   


}

//MARK: - Tableview Operations
extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.MyPhotosCell, for: indexPath) as? MyPhotosCell else {
            return UICollectionViewCell()
        }
        
        cell.image.image = UIImage(named: K.Images.hand)
        
        
        
        return cell
    }
    
    
    
    //MARK: - Header Configurations
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: K.HeaderView, for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 3) // Height of header
    }
    
    
}
