//
//  LogInViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 22.03.2023.
//

import Firebase


struct SignInViewModel: SignInVCProtocol {
    func singInManager(email: String, password: String, completionHandler: @escaping(Error?)->() ) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, err in
            completionHandler(err)
        }
    }
    
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?)->() )  {
        Auth.auth().createUser(withEmail: email, password: password) { authData, err in
            completionHandler(err)
        }
    }
}


