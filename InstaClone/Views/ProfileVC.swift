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
    var isOwnerVisiting = false
  
    //MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.images.removeAll()
        
        viewModel.getUsersPosts(with: email ?? currentUserEmail) { [unowned self] image, isReadyToReload in
            
            self.images.append(image)
            if isReadyToReload {
                calculateCollectionViewHeight(with: images.count)
                self.reusableView.collectionView.reloadData()
            }
        }
        
        navigationController?.navigationBar.backItem?.title = ""
        email == nil ? isOwnerVisiting = true : ()
        determineProfilePicture()
    }
    
    
    //MARK: - IBActions
    
    
    
    //MARK: - Functions
    private func initialSetup() {
        reusableView.collectionView.dataSource = self
        reusableView.collectionView.delegate = self
        reusableView.delegate = self
        
        let nibCell = UINib(nibName: K.MyPhotosCell, bundle: nil)
        reusableView.collectionView.register(nibCell, forCellWithReuseIdentifier: K.MyPhotosCell)
    }
    
    private func calculateCollectionViewHeight(with imageCount: Int) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenHeight = windowScene.screen.bounds.size.height
        let headerViewHeight = screenHeight * reusableView.headerViewHeight.multiplier
        let collectionViewCellHeight = reusableView.collectionView.frame.width/3
        let howManyRows = CGFloat(imageCount / 3) + 2
        let collectionViewHeight = howManyRows * collectionViewCellHeight
        reusableView.viewHeight.constant = headerViewHeight + collectionViewHeight - screenHeight
    }
    
    
    private func ownerVisiting() async {
        do{
            let (fetchedImage, id) = try await viewModel.getProfilePicture()
            self.id = id
            self.reusableView.profilePicture.image = fetchedImage
            self.reusableView.userEmail.text = currentUserEmail
            self.reusableView.setImageInteractable()
            
        } catch {
            print("\(ErrorTypes.noDocumentId) or \(ErrorTypes.noDocumentId)")
        }
    
    }
    
    private func determineProfilePicture() {
        
        if isOwnerVisiting {
            Task {
                await ownerVisiting()
            }
        } else {
            reusableView.profilePicture.image = image
            navigationItem.title = email
            reusableView.userEmail.text = email
        }
//        print(reusableView.profilePicture.frame.width)
//        reusableView.profilePicture.layer.cornerRadius = reusableView.profilePicture.frame.width / 2
//        reusableView.profilePicture.clipsToBounds = true
       
    }
    
    

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
    
    
    

}

//MARK: - ReusableViewToProfileVCProtocol
extension ProfileVC: ReusableViewToProfileVCProtocol {
    
    func addNewProfilePicture(image: UIImage) async {
        viewModel.deleteProfilePicture(id: id) { [self] isSuccesDeleting in
            
            if isSuccesDeleting {
                reusableView.profilePicture.image = image
                
                viewModel.addProfilePicture(image: reusableView.profilePicture) { [self] in
                    
                    Task{
                        let (_, id) = try await viewModel.getProfilePicture()
                        self.id = id
                    }
                    
                                 
                }
            }
        }
    }
    
    func pickerPresent(picker: UIImagePickerController) {
        present(picker, animated: true)
    }
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
