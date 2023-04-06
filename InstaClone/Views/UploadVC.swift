//
//  UploadVC.swift
//  InstaClone
//
//  Created by halil dikişli on 10.03.2023.
//

import UIKit

protocol UploadVCProtocol {
    func uploadData(image: UIImageView,comment: String , completionHandler: @escaping(Error?)->())
}


class UploadVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet private weak var commentText: UITextField!
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var uploadOutlet: UIButton!
    
    //MARK: - Properties
    private var viewModel = UploadViewModel()
    
    //MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.delegate = self
        setImageInteractable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectImage()
    }
    
    //MARK: - IBActions
    @IBAction private func uploadTap(_ sender: UIButton) {
        
        if image.image == UIImage(named: "select3") {
            showAlert(mainTitle: "Select image", message: "Select an image before update!", actionButtonTitle: "OK")
            return
        }
        
        viewModel.uploadData(image: image, comment: commentText.text ?? "") { err in
            if err != nil {
                self.showAlert(mainTitle: "Error!", message: err?.localizedDescription ?? "Error in metadata", actionButtonTitle: "OK")
            }
        }
        
        //Go to Feed when uploading is done
        self.commentText.text = ""
        self.image.image = UIImage(named: "hand")
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelTap(_ sender: UIButton) {
        self.image.image = UIImage(named: "hand")
        self.commentText.text = ""
    }
    //MARK: - Functions
    
    private func setImageInteractable() {
        image.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTap)
        image.image = UIImage(named: "hand")
    }
}

//MARK: - Image Picking
extension UploadVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
}

//MARK: - Text Field
extension UploadVC: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentText.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentText.endEditing(true)
    }
    
    
}
