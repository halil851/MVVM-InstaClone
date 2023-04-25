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
    
    func getCurrentUsersPosts(completion: @escaping(UIImage) -> Void) {
        
        let query = db.collection(K.Posts)
            .whereField(K.Document.postedBy, isEqualTo: currentUserEmail)
            .order(by: K.Document.date)
        
        query.getDocuments { snapshot, err in
            if err != nil {
                print(err.debugDescription)
                return}
            
            guard let snapshot = snapshot else {
                print(err.debugDescription)
                return}
            
            print(snapshot.count)
            
            for document in snapshot.documents {
                
                if let imageUrlString = document.get(K.Document.imageUrl) as? String {
                   let imageURL = URL(string: imageUrlString)
                    
                    SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) { image, data, error, cacheType, finished, _ in
                        if let error = error {
                            print("Error downloading image: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let image = image else {return}
                        completion(image)
                    }
                    
                    
                    
                }
            }
            
            
            
            
        }
    }
    
}
