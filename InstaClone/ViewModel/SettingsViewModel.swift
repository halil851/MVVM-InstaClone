//
//  SettingsViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase

protocol SettingVCProtocol {
    func signOut(completionHandler: @escaping(_ success: Bool, Error?)->())
}

struct SettingsViewModel: SettingVCProtocol {
    
    func signOut(completionHandler: @escaping(_ success: Bool, Error?)->()) {
        do {
            try Auth.auth().signOut()
            completionHandler(true, nil)
            
        } catch {
            completionHandler(false, error)
        }
    }

}
