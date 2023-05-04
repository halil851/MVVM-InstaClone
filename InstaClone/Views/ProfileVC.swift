//
//  ProfileVC.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

class ProfileVC: UIViewController {
    
    //MARK: - IBOutlets
    
    //MARK: - Properties
    @IBOutlet weak var reusableView: ReusableView!
    let viewModel = ProfileViewModel()
    var images = [UIImage]()
    var image: UIImage?
    var email: String?
    var id = String()
  
    //MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        reusableView.collectionView.dataSource = self
        reusableView.collectionView.delegate = self
        
        let nibCell = UINib(nibName: K.MyPhotosCell, bundle: nil)
        reusableView.collectionView.register(nibCell, forCellWithReuseIdentifier: K.MyPhotosCell)
        
        navigationItem.title = email
        reusableView.userEmail.text = email
        
        
//        reusableView.profilePicture.image = image
        
        viewModel.getCurrentUsersPosts(with: email ?? currentUserEmail) { [self] image, isReadyToReload in
           
            self.images.append(image)
            if isReadyToReload {
                calculateCollectionViewHeight(with: images.count)
                self.reusableView.collectionView.reloadData()
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backItem?.title = ""
        
        if image == nil {
            setProfilePicture()
        } else {
            reusableView.profilePicture.image = image
        }
        
//        print("viewWillAppear")
//        performSegue(withIdentifier: "YourProfile", sender: nil)
//        images.removeAll()
//        viewModel.getCurrentUsersPosts(with: currentUserEmail, completion: { image, isReadyToReload  in
//            self.images.append(image)
//
////            if isReadyToReload { self.collectionView.reloadData() }
//
//        })
        
    }
    //MARK: - IBActions
    
    
    
    //MARK: - Functions
    private func calculateCollectionViewHeight(with imageCount: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenHeight = windowScene.screen.bounds.size.height
        let headerViewHeight = screenHeight * reusableView.headerViewHeight.multiplier
        let collectionViewCellHeight = reusableView.collectionView.frame.width/3
        let howManyRows = CGFloat(imageCount / 3) + 2
        let collectionViewHeight = howManyRows * collectionViewCellHeight
        reusableView.viewHeight.constant = headerViewHeight + collectionViewHeight - screenHeight
    }
    
    private func setProfilePicture(){

        viewModel.getProfilePicture() { fetchedImage, id in
            guard let id = id else {return}
            self.id = id
            self.reusableView.profilePicture.image = fetchedImage

        }

    }
  
//    private func setProfilePicture() async -> UIImage? {
//
//        let image: UIImage? = await viewModel.getProfilePicture() { fetchedImage, id in
//            guard let id = id else {return}
//            self.id = id
//            self.reusableView.profilePicture.image = fetchedImage
//
//
//        }
//        return image
//
//    }
    
   


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
    
    
    
//    //MARK: - Header Configurations
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: K.HeaderView, for: indexPath) as? MyPhotosHeaderView else {
//            return UICollectionReusableView()
//        }
//        view.delegate = self
//        return view
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2) // Height of header
//    }
//
//
}



//MARK: - Header View Protocol
extension ProfileVC: HeaderViewToProfileVCProtocol {
    func pickerPresent(picker: UIImagePickerController) {
        present(picker, animated: true)
    }
}
