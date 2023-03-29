//
//  SettingsViewModel.swift
//  InstaClone
//
//  Created by halil dikişli on 23.03.2023.
//

import Firebase


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
