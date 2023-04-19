//
//  Constants.swift
//  InstaClone
//
//  Created by halil dikişli on 21.03.2023.
//

import Foundation

struct K {
    static let Posts = "Posts"
      
    static let media = "media"
    
    struct Document {
        static let date = "date"
        static let imageUrl = "imageUrl"
        static let likes = "likes"
        static let likedBy = "likedBy"
        static let postComment = "postComment"
        static let postedBy = "postedBy"
        static let storageID = "storageID"
    }
    
    struct Images {
        static let heartRedFill = "heart.red.fill"
        static let heartBold = "heart.bold"
    }
    
}

var isFirstRefreshAfterUploading = false
