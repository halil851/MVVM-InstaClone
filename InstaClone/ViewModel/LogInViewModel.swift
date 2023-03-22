//
//  LogInViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 22.03.2023.
//

import Foundation
import Firebase

protocol LogInViewModelDelegate: AnyObject {
    func getInfo(email: String, password: String) -> (Error?, AuthDataResult?)
}

struct LogInViewModel {

    func logInManager(email: String, password: String, completionHandler: @escaping(Error?, AuthDataResult?)->() ) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, err in
            completionHandler(err, authData)
        }
    }
    
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?, AuthDataResult?)->() )  {
        Auth.auth().createUser(withEmail: email, password: password) { authData, err in
            completionHandler(err, authData)
        }
    }
    
    
    
}
