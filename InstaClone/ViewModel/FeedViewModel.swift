//
//  FeedViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase
import SDWebImage

class FeedViewModel: FeedVCProtocol {
    
    private let db = Firestore.firestore()
    
    var emails = [String]()
    var comments = [String]()
    var images = [UIImage]()
    var imagesHeights = [CGFloat]()
    var ids = [String]()
    var storageID = [String]()
    var whoLiked = [[String]]()
    var date = [DateComponents]()
    var profilePictureSDictionary = [String:UIImage]()
    var isPaginating = false
    
    private var query: Query? = nil
    private var firstImageURLAfterUploading = String()
    private let pageSize = 5
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFirstProfileVisit = true
    
    static var indexPath: IndexPath? = nil
    
    //MARK: - Firebase Operations
    // First call you get 5 photo, then get new 5...
    func getDataFromFirestore(_ tableView: UITableView, limit: Int?, pagination: Bool = false, getNewOnes: Bool = false, whosePost: String? = nil) async {
        if pagination {
            isPaginating = true
        }
        
        
        if whosePost != nil { // Visiting Person's Page
            print("PERSON VISIT")
            guard let whosePost = whosePost else {return}
            
            if isFirstProfileVisit {
                guard let indexRow = FeedViewModel.indexPath?.row else {return}
                let tempQuery = db.collection(K.Posts)
                    .order(by: K.Document.date, descending: true)
                    .whereField(K.Document.postedBy, isEqualTo: whosePost)
                    .limit(to: indexRow + 2)
                query = tempQuery
                
            } else {
                let tempQuery = db.collection(K.Posts)
                    .order(by: K.Document.date, descending: true)
                    .whereField(K.Document.postedBy, isEqualTo: whosePost)
                    .limit(to: 2)
                query = tempQuery
            }
            
        } else {  // Main Page
            print("MAIN PAGE")
            let tempQuery = db.collection(K.Posts)
                .order(by: K.Document.date, descending: true)
                .limit(to: limit ?? pageSize)
            query = tempQuery
            isFirstProfileVisit = true
            
        }
        guard var query = query else {return}
        
        
        //If Firebase datas have been called before, and not refreshing. It gets last post and adds ONLY new ones.
        if let lastSnapshot = lastDocumentSnapshot, !getNewOnes {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        do {
            let snapshot = try await query.getDocuments()
            if let newLastSnapshot = await self.prepareAppending(tableView, snapshot, getNewOnes: getNewOnes) {
                self.lastDocumentSnapshot = newLastSnapshot
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    private func prepareAppending(_ tableView: UITableView,_ snapshot: QuerySnapshot, getNewOnes: Bool) async -> DocumentSnapshot? {
        
        print("\(snapshot.count) data called")
        var newLastSnapshot: DocumentSnapshot? = nil
        
        //When pull to refresh run this works, and remove all arrays to make room for refreshing. When paginating this is not running.
        if getNewOnes {
            self.removeAllArrays()
        }
        
        for (index,document) in snapshot.documents.enumerated() {
            
            await append(document, tableView, snapshotCount: snapshot.count, index: index)
            newLastSnapshot = document
        }
        return newLastSnapshot
    }
    
    
    private func append(_ document: QueryDocumentSnapshot, _ tableView: UITableView, snapshotCount: Int, index: Int) async {
        guard let imageUrl = document.get(K.Document.imageUrl) as? String  else { return }
        //Appending start first with downloading images. When ONE image downloaded, next others.
        await downloadImagesAndAppend(imageUrl)
        
        let id = document.documentID
        
        //Add items when reloading. Mostly run this part.
        getPostInfo { postedBy, storageID, comment, like, date in
            self.ids.append(id)
            self.emails.append(postedBy)
            self.storageID.append(storageID)
            self.comments.append(comment)
            self.whoLiked.append(like)
            self.date.append(dateConfig(date))
            
            //Reload table, after all data called from Firebase
            if index == snapshotCount - 1 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    tableView.reloadData()
                    
                    if FeedViewModel.indexPath != nil {
                        tableView.scrollToRow(at: FeedViewModel.indexPath!, at: .top, animated: false)
                        FeedViewModel.indexPath = nil
                        self.isFirstProfileVisit = false
                    }
                    self.isPaginating = false
                })
            }
        }
        
        func dateConfig(_ date: Timestamp) -> DateComponents {
            let uploadDate = Date(timeIntervalSince1970: TimeInterval(date.seconds))
            let now = Date()
            // Calculation the time between 2 dates
            let calendar = Calendar.current
            let timeDifference = calendar.dateComponents([.year, .weekOfMonth, .month, .day, .hour, .minute], from: uploadDate, to: now)
            return timeDifference
        }
        
        //Safely Unwrap informations from Firebase
        func getPostInfo(complation: @escaping(_ postedBy: String, _ storageID: String, _ comment: String, _ like: [String], _ date: Timestamp)->Void){
            if let postedBy = document.get(K.Document.postedBy) as? String,
               let storageID = document.get(K.Document.storageID) as? String,
               let comment = document.get(K.Document.postComment) as? String,
               let like = document.get(K.Document.likedBy) as? [String],
               let date = document.get(K.Document.date) as? Timestamp{
                
                self.fetchThumbnail(userMail: postedBy)
                complation(postedBy, storageID, comment, like, date)
            }
        }
        
        
    }
    
    private func downloadImagesAndAppend(_ imageURL: String) async {
        let imageUrl = URL(string: imageURL)
        do {
            let image = try await ProfileViewModel.loadImage(with: imageUrl)
            
            // Add the image to the array
            self.images.append(image)
            self.calculateNewImageSize(image)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func calculateNewImageSize(_ image: UIImage) {
        //Takes orijinal image sizes and calculate to fit the screen by keeping aspect ratio.
        let imageSize = image.size
        let phoneScreenWidth = UIScreen.main.bounds.width
        let coefficient = imageSize.width / phoneScreenWidth
        let newHeight = imageSize.height / coefficient
        
        imagesHeights.append(newHeight)
    }
    
    
    func fetchThumbnail(userMail: String) {
        
        getProfilePicture(who: userMail) {  image, _ in
            self.profilePictureSDictionary.updateValue(image, forKey: userMail)
        }
        
    }
    
    
    func getProfilePicture(who: String = currentUserEmail, isRequestFromProfilePage: Bool = false, completion: @escaping (UIImage, String?)-> Void) {
        
        let query = db.collection(K.profilePictures)
            .whereField(K.Document.postedBy, isEqualTo: who)
        
        
        query.getDocuments { snapshot, err in
            if err != nil {
                print(err.debugDescription)
                return}
            
            guard let snapshot = snapshot else {
                print(err.debugDescription)
                return}
            
            guard let imageUrlString = snapshot.documents.first?.get(K.Document.imageUrl) as? String else {return}
            let imageURL = URL(string: imageUrlString)
            
            guard let id = snapshot.documents.first?.documentID else {return}
            
            SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, data, error, cacheType, finished, _ in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                
                guard let image = image else {return}
                completion(image,id)
                
            }
        }
    }
    private func removeAllArrays() {
        self.emails.removeAll()
        self.comments.removeAll()
        self.ids.removeAll()
        self.storageID.removeAll()
        self.whoLiked.removeAll()
        self.date.removeAll()
        self.images.removeAll()
        self.imagesHeights.removeAll()
    }
    
}
//MARK: - UI Operations
extension FeedViewModel {
    //Decide singular or plural
    func likeOrLikes(indexRow: Int) -> String {
        
        let likesCount = whoLiked[indexRow].count
        if likesCount > 1 {
            return "\(likesCount) likes"
        }
        return "\(likesCount) like"
    }
    
    
    func uploadDate(indexRow: Int) -> String {
        //Decide singular or plural and the date
        guard let year = date[indexRow].year else {return ""}
        if year > 0 {
            return singularPluralDate(date: year, "year")
        }
        
        guard let month = date[indexRow].month else {return ""}
        if month > 0 {
            return singularPluralDate(date: month, "month")
        }
        
        guard let week = date[indexRow].weekOfMonth else {return ""}
        if week > 0 {
            return singularPluralDate(date: week, "week")
        }
        
        guard let day = date[indexRow].day else {return ""}
        if day > 0 {
            return singularPluralDate(date: day, "day")
        }
        
        guard let hour = date[indexRow].hour else {return ""}
        if hour > 0 {
            return singularPluralDate(date: hour, "hour")
        }
        
        guard let minute = date[indexRow].minute else {return ""}
        if minute == 0 {
            return "now"
        }
        return singularPluralDate(date: minute, "min")
    }
    //Decide singular or plural Date
    private func singularPluralDate(date: Int, _ str: String) -> String{
        if date == 1 {
            return "\(date) \(str) ago"
        }
        return "\(date) \(str)s ago"
    }
    
    // User can only edit or delete own post
    func isOptionsButtonHidden(user: String) -> Bool {
        if user == currentUserEmail {
            return false
        }
        return true
    }
}



