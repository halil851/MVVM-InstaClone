//
//  ProfileVC.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import UIKit

class ProfileVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var reusableView: ReusableView!

    //MARK: - Properties

    let viewModel = ProfileViewModel()
    var images = [UIImage]()
    var image: UIImage?
    var email: String?
    var id = String()
    var isOwnerVisiting = false
    let fetchProfilePicture: FetchThumbnail = Thumbnail()
  
    //MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchImages()
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
    
    private func fetchImages() {
        self.images.removeAll()
        
        Task {
            guard let images = await viewModel.getUsersPosts(with: email ?? currentUserEmail) else {return}
            self.images = images
            calculateCollectionViewHeight(with: images.count)
            self.reusableView.collectionView.reloadData()
        }
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
    }
    
    private func ownerVisiting() async {
        do{
//            let (fetchedImage, id) = try await ProfileViewModel.getProfilePicture()
            let (fetchedImage, id) = try await fetchProfilePicture.fetchThumbnail()
            self.id = id
            self.reusableView.profilePicture.image = fetchedImage
            self.reusableView.userEmail.text = currentUserEmail
            self.reusableView.setImageInteractable()
            
        } catch {
            print(error.localizedDescription)
        }
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
        cell.delegate = self
        cell.image.image = images[indexPath.row]
        
        return cell
    }
    
    
    //MARK: - Cell Sizes and Edges
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 - 2.0, height: collectionView.frame.width/3)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FeedViewModel.indexPath = indexPath
        performSegue(withIdentifier: "PersonsPosts", sender: nil)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

}

//MARK: - ReusableViewToProfileVCProtocol
extension ProfileVC: ReusableViewDelegate {
    
    func addNewProfilePicture(image: UIImage) async {
        do {
            if await viewModel.isSuccesDeletingProfilePicture(id: id) {
                
                reusableView.profilePicture.image = image
                let newProfilePicture: NewThumbnail = Thumbnail(image: image)
                await newProfilePicture.addNewThumbnail(quality: .good)
                
                let (_, id) = try await fetchProfilePicture.fetchThumbnail()
                
//                let (_, id) = try await ProfileViewModel.getProfilePicture()
                self.id = id
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pickerPresent(picker: UIImagePickerController) {
        present(picker, animated: true)
    }
}

extension ProfileVC: MyPhotosCellToProfileVCDelegate {
    func performSegue() {
        performSegue(withIdentifier: "PersonsPosts", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PersonsPosts"{
            
            if let destinationVC = segue.destination as? FeedVC {
                destinationVC.delegate = self
                destinationVC.visitor = email ?? currentUserEmail
            }
            
        }
        
    }
    
}

extension ProfileVC: ReloadAfterPresentation {
    func reloadAfterDismissModalPresentation() {
        viewWillAppear(true)
    }
    
    
}

    //MARK: - Header Configurations
/*
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
*/
