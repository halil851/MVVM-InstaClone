//
//  SettingsVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit

protocol SettingVCProtocol {
    func signOut(completionHandler: @escaping(_ success: Bool, Error?)->())
}

class SettingsVC: UIViewController {
    //MARK: - IBOutlets

    //MARK: - Properties
    var viewModel: SettingVCProtocol = SettingsViewModel()
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - IBActions
    @IBAction func signOut(_ sender: UIButton) {
        viewModel.signOut { success, err in
            if err != nil {
                self.showAlert(mainTitle: "Error!", message: err?.localizedDescription ?? "Error while signing out.", actionButtonTitle: "OK")
                return
            }
            self.performSegue(withIdentifier: "toViewController", sender: nil)
            
        }
    }
    //MARK: - Functions

}










