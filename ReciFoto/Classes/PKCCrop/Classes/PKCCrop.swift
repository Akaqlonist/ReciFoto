//
//  Test.swift
//  Pods
//
//  Created by guanho on 2017. 1. 19..
//
//

import Foundation
import UIKit


// MARK: - PKCCropDelegate
@objc public protocol PKCCropDelegate{
    //If this function is set to false, the setting window will not be displayed automatically when the user does not give permission. If it is set to true or not, the setting window will be automatically opened.
    
    @objc optional func pkcCropAccessPermissionsChange() -> Bool
    
    //Called when the pkcCropAccessPermissionsChange function is set to false and the user has not granted permission.
    
    @objc optional func pkcCropAccessPermissionsDenied()
    
    //You must put in the ViewController at this time.
    
    func pkcCropController() -> UIViewController
    
    //The delegate to which the image is passed since the crop.
    
    func pkcCropImage(_ image: UIImage)
}

// MARK: - PKCCropPictureDelegate
//This is the delegate used by CropViewController, CameraViewController, and PhotoViewController.

protocol PKCCropPictureDelegate {
    func pkcCropPicture(_ image: UIImage)
}


// MARK: - PKCCrop
open class PKCCrop: NSObject {
    weak open var delegate: PKCCropDelegate?
    
    fileprivate var pkcCheck: PKCCheck = PKCCheck()
    
    // MARK: - init
    public override init() {
        super.init()
        self.pkcCheck.delegate = self
    }
    
    
    open func cameraCrop(){
        self.pkcCheck.cameraAccessCheck()
    }
    open func photoCrop(){
        self.pkcCheck.photoAccessCheck()
    }
    open func otherCrop(_ image: UIImage){
        let vc = self.delegate?.pkcCropController()
        let pkcCropViewController = PKCCropViewController()
        pkcCropViewController.delegate = self
        pkcCropViewController.image = image
        pkcCropViewController.cropType = CropType.other
        vc?.present(pkcCropViewController, animated: true, completion: nil)
    }
}

// MARK: - extension PKCCheckDelegate
extension PKCCrop: PKCCheckDelegate{
    public func pkcCheckCameraPermissionDenied() {
        let change = self.delegate?.pkcCropAccessPermissionsChange?()
        if change == nil || change == true{
            self.pkcCheck.permissionsChange()
        }else{
            self.delegate?.pkcCropAccessPermissionsDenied?()
        }
    }
    
    public func pkcCheckCameraPermissionGranted() {
        let vc = self.delegate?.pkcCropController()
        let pkcCameraViewController = PKCCameraViewController()
        pkcCameraViewController.delegate = self
        let navVC = UINavigationController(rootViewController: pkcCameraViewController)
        navVC.isNavigationBarHidden = true
        navVC.isToolbarHidden = true
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                vc?.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    public func pkcCheckPhotoPermissionDenied() {
        let change = self.delegate?.pkcCropAccessPermissionsChange?()
        if change == nil || change == true{
            self.pkcCheck.permissionsChange()
        }else{
            self.delegate?.pkcCropAccessPermissionsDenied?()
        }
    }
    
    public func pkcCheckPhotoPermissionGranted() {
        let vc = self.delegate?.pkcCropController()
        let pkcPhotoViewController = PKCPhotoViewController()
        pkcPhotoViewController.delegate = self
        let navVC = UINavigationController(rootViewController: pkcPhotoViewController)
        navVC.isNavigationBarHidden = true
        navVC.isToolbarHidden = true
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                vc?.present(navVC, animated: true, completion: nil)
            }
        }
    }
}


extension PKCCrop: PKCCropPictureDelegate{
    func pkcCropPicture(_ image: UIImage) {
        self.delegate?.pkcCropImage(image)
    }
}

// MARK: - CropType
enum CropType{
    case camera, photo, other
}


// MARK: - Filter
public struct Filter{
    var name: String
    var filter: CIFilter
    var image: UIImage
}

public enum PKCCropType{
    //freeRate And margin possible

    case freeRateAndMargin
    
    //freeRate And margin impossible

    case freeRateAndNoneMargin
    
    //rate And margin impossible

    case rateAndMargin
    
    //rate And margin impossible

    case rateAndNoneMargin
    
    //Rate crop and rotate the image. The image is in aspectFill format and the margins disappear. In addition, the rotation function is added. If you want to disable rotation, you can set isRotate to false in PKCCropManager.

    case rateAndRotate
    
    //Free crop and rotate images. The image is in aspectFill format and the margins disappear. In addition, the rotation function is added. If you want to disable rotation, you can set isRotate to false in PKCCropManager.

    case freeRateAndRotate
    
    //Ratio is a circle crop that allows cropping and spacing.

    case rateAndMarginCircle
    
    //Ratio is a circle crop that does not allow cropping and spacing.

    case rateAndNoneMarginCircle
    
    //It is a circle crop which can rotate ratio and image.

    case rateAndRotateCircle
}

public class PKCCropManager{
    // MARK: - singleton
    public static let shared = PKCCropManager()
    
    //You can add or remove filters. If you do not insert a filter or insert only one, when you swipe on the camera screen, there is no response and the filter button disappears.

    lazy open var cameraFilters : [Filter] = {
        var array = [Filter]()
        array.append(Filter(name: "Normal", filter: CIFilter(name: "CIColorControls")!, image: UIImage(named: "pkc_crop_filter_nomal.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Mono", filter: CIFilter(name: "CIPhotoEffectMono")!, image: UIImage(named: "pkc_crop_filter_mono.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Chrome", filter: CIFilter(name: "CIPhotoEffectChrome")!, image: UIImage(named: "pkc_crop_filter_chrome.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Fade", filter: CIFilter(name: "CIPhotoEffectFade")!, image: UIImage(named: "pkc_crop_filter_fade.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Instant", filter: CIFilter(name: "CIPhotoEffectInstant")!, image: UIImage(named: "pkc_crop_filter_instant.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Noir", filter: CIFilter(name: "CIPhotoEffectNoir")!, image: UIImage(named: "pkc_crop_filter_noir.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Process", filter: CIFilter(name: "CIPhotoEffectProcess")!, image: UIImage(named: "pkc_crop_filter_process.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Tonal", filter: CIFilter(name: "CIPhotoEffectTonal")!, image: UIImage(named: "pkc_crop_filter_tonal.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        array.append(Filter(name: "Transfer", filter: CIFilter(name: "CIPhotoEffectTransfer")!, image: UIImage(named: "pkc_crop_filter_transfer.png", in: Bundle(for: PKCCrop.self), compatibleWith: nil)!))
        return array
    }()
    
    
    //Zoom the image before cropping.

    open var isZoom : Bool = true
    
    
    
    //An arrow animation appears on the Zoom screen.

    open var isZoomAnimation: Bool = true
    
    
    
    
    //Added in rateAndRotate and freeRateAndRotate and rateAndRotateCircle. If this value is set to true, the image rotation function is added.
    //rateAndRotate, rateAndRotateCircle freeRateAndRotate에서 추가된 기능입니다. 이 값을 true로 하면 이미지 회전 기능이 추가됩니다.
    open var isRotate : Bool = true
    
    
    
    //Set the crop type

    open var cropType: PKCCropType = PKCCropType.freeRateAndMargin
    
    
    
    //Set the crop ratio.

    open func setRate(rateWidth: CGFloat, rateHeight: CGFloat) -> Bool{
        if rateWidth/rateHeight < 2 && rateHeight/rateWidth < 2{
            PKCCropManager.shared.rateWidth = rateWidth
            PKCCropManager.shared.rateHeight = rateHeight
            return true
        }else{

            print("Do not make the difference between width and height more than twice")
            return false
        }
    }
    var rateWidth: CGFloat = 1
    var rateHeight: CGFloat = 1
}
