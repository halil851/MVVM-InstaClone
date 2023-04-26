//
//  ProfileViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 24.04.2023.
//

import Firebase
import SDWebImage


struct ProfileViewModel {
    
    private let db = Firestore.firestore()
    
    func getCurrentUsersPosts(completion: @escaping(UIImage, _ isReadyToReload: Bool) -> Void) {
        
        let query = db.collection(K.Posts)
            .whereField(K.Document.postedBy, isEqualTo: currentUserEmail)
            .order(by: K.Document.date, descending: true)
        
        query.getDocuments { snapshot, err in
            if err != nil {
                print(err.debugDescription)
                return}
            
            guard let snapshot = snapshot else {
                print(err.debugDescription)
                return}
            var isReadyToReload = false
            
            for document in snapshot.documents {
                
                guard let imageUrlString = document.get(K.Document.imageUrl) as? String  else {return}
                let imageURL = URL(string: imageUrlString)
                
                SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, data, error, cacheType, finished, _ in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let image = image else {return}
                    
                    if document == snapshot.documents.last { isReadyToReload = true}
                    
                    completion(image, isReadyToReload)
                }
                
                
            }
            
        }
    }
    
}
