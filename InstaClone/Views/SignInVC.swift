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
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        eMailField.delegate = self
        passwordField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
 
    //MARK: - IBActions
    @IBAction private func signInTap(_ sender: UIButton? = nil) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        viewModel.signInManager(email: textFields().user.email,
                                password: textFields().user.password) { [weak self] err in
            
            if err != nil {
                self?.showAlert(mainTitle: "Error Log In", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            guard let email = self?.textFields().user.email else {return}
            currentUserEmail = email
            self?.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    @IBAction private func signUpTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        viewModel.signUpManager(email: textFields().user.email,
                                password: textFields().user.password) { [weak self] err in
            if err != nil {
                self?.showAlert(mainTitle: "Error Sign Up", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            guard let email = self?.textFields().user.email else {return}
            currentUserEmail = email
            self?.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    //MARK: - Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenHeight = windowScene.screen.bounds.size.height
        let heightOfSignInButtonFromBottom = screenHeight - signInOutlet.frame.maxY
        guard heightOfSignInButtonFromBottom < keyboardSize.height else {return}
        let upValue = keyboardSize.height - heightOfSignInButtonFromBottom + heightOfSignInButtonFromBottom * 0.15
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= upValue
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    // If Textfields are empty then return with an alert.
    private func textFields() -> (isItEmpty: Bool, user: User) {
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

