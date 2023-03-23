//
//  LogInViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 22.03.2023.
//

import Firebase

protocol SignInVCProtocol {
    func singInManager(email: String, password: String, completionHandler: @escaping(Error?, AuthDataResult?)->() )
    
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?, AuthDataResult?)->() )
}




struct SignInViewModel: SignInVCProtocol {
    func singInManager(email: String, password: String, completionHandler: @escaping(Error?, AuthDataResult?)->() ) {
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


