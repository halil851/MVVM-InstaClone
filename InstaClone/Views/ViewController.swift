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
                self.showAlert(title: "Error", message: err!.localizedDescription, .alert, actionTitle: "OK", actionStyle: .default)
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
                self.showAlert(title: "Error", message: err!.localizedDescription, .alert, actionTitle: "OK", actionStyle: .default)
                return
            }
            
            self.performSegue(withIdentifier: "toFeedVC", sender: nil)
        }
    }
    
    
    
    
    func showAlert(title: String, message: String, _ style: UIAlertController.Style, actionTitle: String, actionStyle: UIAlertAction.Style){
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okButton = UIAlertAction(title: actionTitle, style: actionStyle)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    // If Textfields are empty then return with an alert.
    func textFields() -> (isItEmpty: Bool, email: String, password: String) {
        guard let email = eMailField.text,
              let password = passwordField.text,
              email != "",
              password != "" else {
            showAlert(title: "Empty field!", message: "Username or Password is empty.", .alert, actionTitle: "OK", actionStyle: .default)
            return (true, "", "")
        }
        return (false, email, password)
    }
    
}

