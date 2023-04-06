//
//  ViewController.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit

protocol SignInVCProtocol {
    func singInManager(email: String, password: String, completionHandler: @escaping(Error?)->() )
    func signUpManager(email: String, password: String, completionHandler: @escaping(Error?)->() )
}

class SignInVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var eMailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    
    //MARK: - Properties
    private var viewModel: SignInVCProtocol = SignInViewModel()
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
 
    //MARK: - IBActions
    @IBAction private func signInTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        viewModel.singInManager(email: textFields().email, password: textFields().password) { err in
            
            if err != nil {
                self.showAlert(mainTitle: "Error Log In", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    @IBAction private func signUpTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        viewModel.signUpManager(email: textFields().email, password: textFields().password) { err in
            if err != nil {
                self.showAlert(mainTitle: "Error Sign Up", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    //MARK: - Functions
    // If Textfields are empty then return with an alert.
    private func textFields() -> (isItEmpty: Bool, email: String, password: String) {
        guard let email = eMailField.text,
              let password = passwordField.text,
              email != "",
              password != "" else {
            showAlert(mainTitle: "Empty field!", message: "Username or Password is empty.", actionButtonTitle: "OK")
            return (true, "", "")
        }
        return (false, email, password)
    }
}

