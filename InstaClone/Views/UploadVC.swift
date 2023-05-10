//
//  UploadVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit
import YPImagePicker

protocol UploadVCProtocol {
    func uploadData(image: UIImageView,comment: String , completionHandler: @escaping(Error?)->())
}


class UploadVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var uploadOutlet: UIButton!
    
    //MARK: - Properties
    private var viewModel = UploadViewModel()
    private var isSelectingImage = false
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        setImageInteractable()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if !isSelectingImage { selectImage() }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {return}
        let screenHeight = windowScene.screen.bounds.size.height
        let heightOfUploadButtonFromBottom = screenHeight - uploadOutlet.frame.maxY
        guard heightOfUploadButtonFromBottom < keyboardSize.height else {return}
        let upValue = keyboardSize.height - heightOfUploadButtonFromBottom + heightOfUploadButtonFromBottom * 0.15
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= upValue
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    //MARK: - IBActions
    @IBAction private func uploadTap(_ sender: UIButton) {
        
        if image.image == UIImage(named: K.Images.hand) {
            showAlert(mainTitle: "Select image", message: "Select an image before update!", actionButtonTitle: "OK")
            return
        }
        
        viewModel.uploadData(image: image, comment: commentTextView.text ?? "") { err in
            if err != nil {
                self.showAlert(mainTitle: "Error!", message: err?.localizedDescription ?? "Error in metadata", actionButtonTitle: "OK")
            }
        }
        
        //Go to Feed when uploading is done
        self.commentTextView.text = ""
        self.image.image = UIImage(named: K.Images.hand)
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelTap(_ sender: UIButton) {
        self.image.image = UIImage(named: K.Images.hand)
        self.commentTextView.text = ""
    }
    //MARK: - Functions
    
    private func setImageInteractable() {
        image.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTap)
        image.image = UIImage(named: K.Images.hand)
    }
}

//MARK: - Image Picking
extension UploadVC {
    @objc func selectImage() {
        isSelectingImage = true
        
        var config = YPImagePickerConfiguration()
        config.onlySquareImagesFromCamera = false
        config.startOnScreen = .library
        
        #if targetEnvironment(simulator)
            config.screens = [.library] // Only library can be seen when device is a simulator
        #endif
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let photo = items.singlePhoto {
                self.image.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
            //Avoid selectImage() method works after select an image or cancel selecting.
            DispatchQueue.global().asyncAfter(deadline: .now()+0.3, execute: {
                self.isSelectingImage = false
            })
        }
        present(picker, animated: true, completion: nil)


    }

}

//MARK: - Text Field
extension UploadVC: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextView.endEditing(true)
    }
    
    
}

