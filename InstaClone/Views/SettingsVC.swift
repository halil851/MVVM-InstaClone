//
//  SettingsVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {
    //MARK: - IBOutlets

    //MARK: - Properties

    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - IBActions
    @IBAction func logoutTap(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
            
        } catch {
            showAlert(mainTitle: "Error!", message: error.localizedDescription, actionButtonTitle: "OK")
        }
    }
    //MARK: - Functions

}










