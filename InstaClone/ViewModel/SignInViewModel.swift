//
//  LogInViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 22.03.2023.
//

import Firebase
import FirebaseStorage
import UIKit.UIImage

var currentUserEmail: String = Auth.auth().currentUser?.email ?? "No One"

struct SignInViewModel: SignInVCProtocol {
    func signInManager(email: String, password: String, completionHandler: @escaping(Error?)->() ) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, err in
            completionHandler(err)
        }
    }
    
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?)->() )  {
        Auth.auth().createUser(withEmail: email, password: password) { authData, err in
            if err == nil {
                print("Default photo will upload.")
                let defaultProfilePicture = Thumbnail()
                Task {
                    await defaultProfilePicture.addNewThumbnail(email: email)
                }
                
            }
            completionHandler(err)
            
        }
    }
}


