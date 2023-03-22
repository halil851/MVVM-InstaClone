//
//  ViewController.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var eMailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func logInTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        Auth.auth().signIn(withEmail: textFields().email, password: textFields().password) { authData, err in
            
            if err != nil {
                self.showAlert(mainTitle: "Error", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    
    
    
    @IBAction func signUpTap(_ sender: UIButton) {
        // If Textfields are empty then return with an alert.
        guard textFields().isItEmpty == false else {return}
        
        Auth.auth().createUser(withEmail: textFields().email, password: textFields().password) { authData, err in
            
            if err != nil {
                self.showAlert(mainTitle: "Error", message: err?.localizedDescription ?? "Error", actionButtonTitle: "OK")
                return
            }
            
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    
    // If Textfields are empty then return with an alert.
    func textFields() -> (isItEmpty: Bool, email: String, password: String) {
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

