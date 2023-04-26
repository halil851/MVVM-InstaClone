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
        selectImage()
    }
    
    
    //MARK: - IBActions
    @IBAction private func uploadTap(_ sender: UIButton) {
        
        if image.image == UIImage(named: K.Images.hand) {
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
        self.image.image = UIImage(named: K.Images.hand)
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func cancelTap(_ sender: UIButton) {
        self.image.image = UIImage(named: K.Images.hand)
        self.commentText.text = ""
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
     
                                
                                
        var config = YPImagePickerConfiguration()
        // [Edit configuration here ...]
        // Build a picker with your configuration
        config.onlySquareImagesFromCamera = false
        config.startOnScreen = .library
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
//                print(photo.fromCamera) // Image source (camera or library)
//                print(photo.image) // Final image selected by the user
//                print(photo.originalImage) // original image selected by the user, unfiltered
//                print(photo.modifiedImage) // Transformed image, can be nil
//                print(photo.exifMeta) // Print exif meta data of original image.
                self.image.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
        
                                

       /*
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        */
    }
    /*
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
             image.image = info[.editedImage] as? UIImage
             self.dismiss(animated: true)
         }
     */
    
    
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
