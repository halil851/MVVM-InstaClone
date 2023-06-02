//
//  Post.swift
//  InstaClone
//
//  Created by halil dikişli on 2.06.2023.
//

import Firebase

struct Post {
    let postedBy: String
    let comment: String
    let imageUrlString: String
    let likedBy: [String]
    let date: FieldValue
    let storageID: String
}
