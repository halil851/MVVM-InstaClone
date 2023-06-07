//
//  Protocols.swift
//  InstaClone
//
//  Created by halil dikişli on 5.06.2023.
//

import UIKit

protocol ReloadAfterPresentation: AnyObject {
    func reloadAfterDismissModalPresentation()
}


protocol FeedVCProtocol {
    var usersPost: [FetchPost] {get set}
    var images: [UIImage] {get set}
    var imagesHeights: [CGFloat] {get set}
    var isPaginating: Bool {get}
    var profilePictureSDictionary: [String:UIImage] {get}
    
    func likeOrLikes(at indexRow: Int) -> String
    func uploadDate(at indexRow: Int) -> String
    func isOptionsButtonHidden(user: String) -> Bool
    func removePosts(index: Int)
}


protocol FetchData {
    func getDataFromFirestore(_ tableView: UITableView, limit: Int?, pagination: Bool, getNewOnes: Bool, whosePost: String?) async
}
extension FetchData {
    func getDataFromFirestore (_ tableView: UITableView, limit: Int? = nil, pagination: Bool = false, getNewOnes: Bool = false, whosePost: String? = nil) async{
       await getDataFromFirestore(tableView, limit: limit, pagination: pagination, getNewOnes: getNewOnes, whosePost: whosePost)
    }
}


protocol PostLikeManagerProtocol {
    func postLikeManager(id: String)
    func postDislikeManager(id: String)
    func isLiked(likesList: [String]) -> Bool
    func likeOrLikes(indexRow: Int, likeCount: Int) -> String
}


protocol DeletePostProtocol {
    func deletePost(id: String, storageID: String)
}


protocol FeedCellToFeedVCDelegate {
    func performSegue(cellIndex: Int, likeList: [String], likeCount: String)
    func showAlert(alert: UIAlertController)
    func manageUIChanges(action: Action,_ indexRow: Int)
    func deleteAnIndex(indexPaths: [IndexPath]) async
    func goToVisitProfile(with userEmail: String?, indexRow: Int)
}


protocol MyPhotosCellToProfileVCDelegate: AnyObject {
    func performSegue()
}


protocol ReusableViewDelegate: AnyObject {
    func pickerPresent(picker: UIImagePickerController)
    func addNewProfilePicture(image: UIImage) async
}


protocol SignInVCProtocol {
    func signInManager(email: String, password: String, completionHandler: @escaping(Error?)->() )
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?)->() )
}


protocol UploadVCProtocol {
    func uploadData(image: UIImageView,comment: String , completionHandler: @escaping(Error?)->())
}


protocol SettingVCProtocol {
    func signOut(completionHandler: @escaping(_ success: Bool, Error?)->())
}


protocol NewThumbnail {
    func addNewThumbnail(email: String, quality: Quality) async
}
extension NewThumbnail {
    func addNewThumbnail(email: String = currentUserEmail, quality: Quality = .normal) async {
        await addNewThumbnail(email: email, quality: quality)
    }
}


protocol FetchThumbnail {
    func fetchThumbnail(email: String) async throws -> (UIImage, String)
}
extension FetchThumbnail {
    func fetchThumbnail(email: String = currentUserEmail) async throws -> (UIImage, String) {
        try await fetchThumbnail(email: email)
    }
}

protocol ImageDownload {
    func image(with url: URL?) async throws -> UIImage
}
