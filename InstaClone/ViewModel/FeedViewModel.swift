//
//  FeedViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase
import SDWebImage

class FeedViewModel: FeedVCProtocol, FetchData {
    
    var images = [UIImage]()
    var imagesHeights = [CGFloat]()
    var profilePictureSDictionary = [String:UIImage]()
    var isPaginating = false
    var usersPost = [FetchPost]()
    
    private let db = Firestore.firestore()
    private var query: Query? = nil
    private var firstImageURLAfterUploading = String()
    private let pageSize = 5
    private var lastDocumentSnapshot: DocumentSnapshot? = nil
    private var isFirstProfileVisit = true
    private var postNumberBeforeReloading = Int()
    
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
        postNumberBeforeReloading = usersPost.count
        
        for (index,document) in snapshot.documents.enumerated() {
            
            await append(with: document, tableView, at: snapshot.count, to: index, getNewOnes: getNewOnes)
            newLastSnapshot = document
        }
        return newLastSnapshot
    }
    
    
    private func append(with document: QueryDocumentSnapshot, _ tableView: UITableView, at snapshotCount: Int, to index: Int, getNewOnes: Bool) async {
        guard let imageUrl = document.get(K.Document.imageUrl) as? String  else { return }
        //Appending start first with downloading images. When ONE image downloaded, next others.
        await downloadImagesAndAppend(imageUrl)
        
        let id = document.documentID
        
        guard let postedBy = document.get(K.Document.postedBy) as? String,
              let storageID = document.get(K.Document.storageID) as? String,
              let comment = document.get(K.Document.postComment) as? String,
              let likedBy = document.get(K.Document.likedBy) as? [String],
              let dateType = document.get(K.Document.date) as? Timestamp else {return}
        
        let date = dateConfig(dateType)
               
        let fetchedPost = FetchPost(postedBy: postedBy, storageID: storageID, comment: comment, likedBy: likedBy, date: date, id: id)
        
        do {
            let (fetchedImage, _) = try await ProfileViewModel.getProfilePicture(whose: fetchedPost.postedBy)
            self.profilePictureSDictionary.updateValue(fetchedImage, forKey: fetchedPost.postedBy)
        } catch {
            print(error.localizedDescription)
        }
        
        usersPost.append(fetchedPost)
        
        //Reload table, after all data called from Firebase
        if index == snapshotCount - 1 {
            
            if getNewOnes, self.postNumberBeforeReloading != 0 { // If reloading
                for _ in 0..<self.postNumberBeforeReloading {
                    self.removePosts(index: 0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                tableView.reloadData()
                
                if FeedViewModel.indexPath != nil {
                    tableView.scrollToRow(at: FeedViewModel.indexPath!, at: .top, animated: false)
                    FeedViewModel.indexPath = nil
                    self.isFirstProfileVisit = false
                }
                self.isPaginating = false
            })
        }
        
        func dateConfig(_ date: Timestamp) -> DateComponents {
            let uploadDate = Date(timeIntervalSince1970: TimeInterval(date.seconds))
            let now = Date()
            // Calculation the time between 2 dates
            let calendar = Calendar.current
            let timeDifference = calendar.dateComponents([.year, .weekOfMonth, .month, .day, .hour, .minute], from: uploadDate, to: now)
            return timeDifference
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
    
    func removePosts(index: Int) {
        
        self.usersPost.remove(at: index)
        self.images.remove(at: index)
        self.imagesHeights.remove(at: index)
    }
    
}
//MARK: - UI Operations
extension FeedViewModel {
    //Decide singular or plural
    func likeOrLikes(at indexRow: Int) -> String {
        
        let likesCount = usersPost[indexRow].likedBy.count
        if likesCount > 1 {
            return "\(likesCount) likes"
        }
        return "\(likesCount) like"
    }
    
    
    func uploadDate(at indexRow: Int) -> String {
        //Decide singular or plural and the date
        guard let year = usersPost[indexRow].date.year else {return ""}
        if year > 0 {
            return singularPluralDate(date: year, "year")
        }
        
        guard let month = usersPost[indexRow].date.month else {return ""}
        if month > 0 {
            return singularPluralDate(date: month, "month")
        }
        
        guard let week = usersPost[indexRow].date.weekOfMonth else {return ""}
        if week > 0 {
            return singularPluralDate(date: week, "week")
        }
        
        guard let day = usersPost[indexRow].date.day else {return ""}
        if day > 0 {
            return singularPluralDate(date: day, "day")
        }
        
        guard let hour = usersPost[indexRow].date.hour else {return ""}
        if hour > 0 {
            return singularPluralDate(date: hour, "hour")
        }
        
        guard let minute = usersPost[indexRow].date.minute else {return ""}
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
