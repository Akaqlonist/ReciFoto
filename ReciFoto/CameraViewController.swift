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
    let pkcCrop = PKCCrop()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Add a Recipe"
        self.pkcCrop.delegate = self
        
        
        let _ = PKCCropManager.shared.setRate(rateWidth: 16, rateHeight: 16)
        PKCCropManager.shared.cropType = .rateAndRotate
        PKCCropManager.shared.isZoomAnimation = false
        PKCCropManager.shared.isZoom = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        self.pkcCrop.cameraCrop()
        self.imageView.image = nil
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
//        let apiRequest = request(String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.upload_recipeV2),
//                                 method: .post, parameters: [Constants.USER_ID_KEY : Me.user.id,
//                                                             Constants.USER_SESSION_KEY : Me.session_id,
//                                                             Constants.RECIPE_TITLE_KEY : self.txtRecipeName.text!,
//                                                             Constants.CONTACT_WEBSITE_KEY : self.txtWebsite.text!])
        let uploadAPIURLConvertable = String(format:"%@%@",Constants.API_URL_DEVELOPMENT,Constants.upload_recipeV2)
        upload(multipartFormData: { multipartFormData in
            multipartFormData.append(UIImagePNGRepresentation(self.imageView.image!)!, withName: "file", fileName: "file.png", mimeType: "image/png")
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
                }
                self.resetContent()
            case .failure(let encodingError):
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
extension CameraViewController: PKCCropDelegate{
    func pkcCropAccessPermissionsChange() -> Bool {
        return true
    }
    func pkcCropAccessPermissionsDenied() {
        
    }
    
    func pkcCropController() -> UIViewController {
        return self
    }
    
    func pkcCropImage(_ image: UIImage) {
        self.imageView.image = image
    }
}
