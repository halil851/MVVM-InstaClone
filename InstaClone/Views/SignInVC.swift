//
//  ViewController.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit

class SignInVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var eMailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet weak var signInOutlet: UIButton!
    
    //MARK: - Properties
    private var viewModel: SignInVCProtocol = SignInViewModel()
    private var adaptiveView: AdaptiveViewKeyboardSetup?
    
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldDelegationSetup()
        adaptiveView = AdaptiveViewKeyboardSetup(view: view, button: signInOutlet)
    }
 
    //MARK: - IBActions
    @IBAction private func signInTap(_ sender: UIButton? = nil) {
        // If Textfields are empty then return with an alert.
        guard textFields().isEmpty == false else {return}
        
        viewModel.signInManager(email: textFields().user.email,
                                password: textFields().user.password) { [weak self] err in
            
            guard err == nil else {self?.showAlert(mainTitle: "Error Sign In", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK"); return}
            guard let email = self?.textFields().user.email else {return}
            currentUserEmail = email
            self?.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    @IBAction private func signUpTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isEmpty == false else {return}
        
        viewModel.signUpManager(email: textFields().user.email,
                                password: textFields().user.password) { [weak self] err in
            
            guard err == nil else {self?.showAlert(mainTitle: "Error Sign Up", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK"); return}
            guard let email = self?.textFields().user.email else {return}
            currentUserEmail = email
            self?.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    //MARK: - Functions
    private func textFieldDelegationSetup() {
        eMailField.delegate = self
        passwordField.delegate = self
    }
    
    // If Textfields are empty then return with an alert.
    private func textFields() -> (isEmpty: Bool, user: User) {
        guard let email = eMailField.text,
              let password = passwordField.text,
              email != "",
              password != "" else {
            showAlert(mainTitle: "Empty field!", message: "Username or Password is empty.", actionButtonTitle: "OK")
            return (true, User(email: "", password: ""))
        }
        let user = User(email: email, password: password)

        return (false, user)
    }
}

//MARK: - TextField Delegate
extension SignInVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        eMailField.endEditing(true)
        passwordField.endEditing(true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == eMailField {
            passwordField.becomeFirstResponder()
            return false
        } else {
            passwordField.endEditing(true)
            eMailField.endEditing(true)
            signInTap()
            return true
        }
    }
}
