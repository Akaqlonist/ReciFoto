//
//  CameraViewController.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnOn: UIButton!
    @IBOutlet weak var btnOff: UIButton!
    @IBOutlet weak var txtRecipeName: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnAddCamera: UIButton!
//    let pkcCrop = PKCCrop()
    @IBOutlet weak var addImageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Add a Recipe"
//        self.pkcCrop.delegate = self
        
        
//        let _ = PKCCropManager.shared.setRate(rateWidth: 16, rateHeight: 16)
//        PKCCropManager.shared.cropType = .rateAndRotate
//        PKCCropManager.shared.isZoomAnimation = false
//        PKCCropManager.shared.isZoom = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraAction(_ sender: UIButton) {
        self.imageView.image = nil
        let actionSheetController = UIAlertController(title: "ReciFoto", message: "Choose your action", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
//            self.pkcCrop.cameraCrop()
            self.presentImagePicker(sourceType: .camera)
        }
        actionSheetController.addAction(cameraActionButton)
        
        let albumActionButton = UIAlertAction(title: "Album", style: .default) { action -> Void in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
        actionSheetController.addAction(albumActionButton)
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(actionSheetController, animated: true, completion: nil)
        }else{
            actionSheetController.modalPresentationStyle = .popover
            let popOver: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popOver.sourceView = self.addImageLabel
            popOver.sourceRect = self.addImageLabel.bounds
            popOver.permittedArrowDirections = .down

            self.present(actionSheetController, animated: true, completion: { 
                
            })
        }
        
    }
    @IBAction func publishAction(_ sender: Any) {
        validation()
    }
    @IBAction func onAction(_ sender: Any) {
        self.btnOn.isSelected = true
        self.btnOff.isSelected = false
    }
    @IBAction func offAction(_ sender: Any) {
        self.btnOn.isSelected = false
        self.btnOff.isSelected = true
    }
    private func presentImagePicker(sourceType : UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if sourceType == .photoLibrary{
                picker.allowsEditing = false
            }else{
                picker.allowsEditing = true
            }
        } else {
            picker.allowsEditing = true
        }
        present(picker, animated: true, completion: nil)
    }
    func validation(){
        let alertController = UIAlertController(title: "ReciFoto", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        if self.txtRecipeName.text == "" {
            alertController.message = "Please input recipe name"
            self.present(alertController, animated: true, completion: {
                self.txtRecipeName.becomeFirstResponder()
            })
        }
        else if self.imageView.image == nil {
            alertController.message = "Please add image to post"
            self.present(alertController, animated: true, completion: {
                
            })
        }
        else{
            if uploadToServer() == 1{
                
            }else{
                
            }
        }
    }
    func uploadToServer() -> Int{
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let uploadAPIURLConvertable = String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.upload_recipeV2)
        upload(multipartFormData: { multipartFormData in
            multipartFormData.append(UIImageJPEGRepresentation(self.imageView.image!, 1.0)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            multipartFormData.append(Me.user.id.data(using: .utf8)!, withName: Constants.USER_ID_KEY)
            multipartFormData.append(Me.session_id.data(using: .utf8)!, withName: Constants.USER_SESSION_KEY)
            multipartFormData.append((self.txtRecipeName.text?.data(using: .utf8)!)!, withName: Constants.RECIPE_TITLE_KEY)
            multipartFormData.append((self.txtWebsite.text?.data(using: .utf8)!)!, withName: Constants.CONTACT_WEBSITE_KEY)
        }, to: uploadAPIURLConvertable)
        { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }
                self.resetContent()
                
            case .failure(let encodingError):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print("error:\(encodingError)")
            }
            
        }
        
        return 1
    }
    func resetContent(){
        self.txtRecipeName.text = ""
        self.txtWebsite.text = ""
        self.imageView.image = nil
        btnOn.isSelected = true
        btnOff.isSelected = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
//extension CameraViewController: PKCCropDelegate{
//    func pkcCropAccessPermissionsChange() -> Bool {
//        return true
//    }
//    func pkcCropAccessPermissionsDenied() {
//        
//    }
//    
//    func pkcCropController() -> UIViewController {
//        return self
//    }
//    
//    func pkcCropImage(_ image: UIImage) {
//        self.imageView.image = image
//    }
//}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            if picker.sourceType == .photoLibrary{
                var image = info[UIImagePickerControllerOriginalImage] as! UIImage
                image = image.cropTo(size: self.imageView.frame.size)
                self.imageView.image = image
            }else{
                let image = info[UIImagePickerControllerEditedImage]
                self.imageView.image = image as! UIImage?
            }
        } else {
            let image = info[UIImagePickerControllerEditedImage]
            self.imageView.image = image as! UIImage?
        }
    }
}
extension UIImage {
    func cropTo(size: CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        var cropWidth: CGFloat = size.width
        var cropHeight: CGFloat = size.height
        
        if (self.size.height < size.height || self.size.width < size.width){
            return self
        }
        
        let heightPercentage = self.size.height/size.height
        let widthPercentage = self.size.width/size.width
        
        if (heightPercentage < widthPercentage) {
            cropHeight = size.height*heightPercentage
            cropWidth = size.width*heightPercentage
        } else {
            cropHeight = size.height*widthPercentage
            cropWidth = size.width*widthPercentage
        }
        
        let posX: CGFloat = (self.size.width - cropWidth)/2
        let posY: CGFloat = (self.size.height - cropHeight)/2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return cropped
    }
}
