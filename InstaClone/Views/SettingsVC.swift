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
    @IBOutlet weak var currentUser: UILabel!
    
    //MARK: - Properties
    private var viewModel: SettingVCProtocol = SettingsViewModel()
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser.text = currentUserEmail

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - IBActions
    @IBAction private func signOut(_ sender: UIButton) {
        viewModel.signOut { [weak self] success, err in
            if err != nil {
                self?.showAlert(mainTitle: "Error!", message: err?.localizedDescription ?? "Error while signing out.", actionButtonTitle: "OK")
                return
            }
            self?.performSegue(withIdentifier: "toSignIn", sender: nil)
            
        }
    }
    //MARK: - Functions

}










