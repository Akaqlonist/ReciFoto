//
//  EditProfileViewController.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

final class EditProfileViewController: FormViewController {
    var is_changed : Bool = false
    var is_photo_changed : Bool = false
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        configure()
    }
    
    // MARK: Private
    
    @objc private func done() {
        if is_changed{
            if is_photo_changed{
                NetworkManger.sharedInstance.updateProfileWithPhotoAPI(image: imageRow.cell.iconView.image!, completionHandler: { (jsonResponse, status) in
                    
                })
            }else{
                NetworkManger.sharedInstance.updateProfileAPI(completionHandler: { (jsonResponse, status) in
                
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    fileprivate lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell") , cellSetup: { imageCell in
            if(Me.img_avatar != nil){
                imageCell.iconView.image = Me.img_avatar
            }
        }).configure(handler: { labelRowFormer in
            labelRowFormer.text = "Choose profile image from library"
            labelRowFormer.rowHeight = 60
            
        }).onSelected({ labelRowFormer in
            self.former.deselect(animated: true)
            self.presentImagePicker()
        })
    }()
    
    private lazy var informationSection: SectionFormer = {
        let usernameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Username"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Your Username"
                $0.text = Me.user.userName
                $0.enabled = false
            }.onTextChanged {changedText in
//                Me.user.userName = $0.text
        }
        
        let phoneRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Phone"
            $0.textField.keyboardType = .numberPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your phone number"
                $0.text = Me.user.userPhone
            }.onTextChanged {changedText in
                self.is_changed = true
                Me.user.userPhone = changedText
        }
        return SectionFormer(rowFormer: usernameRow, phoneRow)
    }()
    func dateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func configure() {
        title = "Edit Profile"
        tableView.contentInset.top = 40
        tableView.contentInset.bottom = 40
        // Create RowFomers
        let nameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Name"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your name"
                $0.text = Me.user.userFullName
            }.onTextChanged { changedText in
                self.is_changed = true
                Me.user.userFullName = changedText
        }
        
        let birthdayRow = InlineDatePickerRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Birthday"
            }.configure {birthdayPicker in
                birthdayPicker.date = Utility.sharedInstance.stringToDate(str: Me.user.userBirthday)
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .date
            }.displayTextFromDate {
                return String.mediumDateNoTime(date: $0)
            }.onDateChanged {changedDate in
                self.is_changed = true
                Me.user.userBirthday = Utility.sharedInstance.dateToString(date: changedDate)
        }
        let introductionRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your self-introduction"
                $0.text = Me.user.userBio
            }.onTextChanged {changedText in
                self.is_changed = true
                Me.user.userBio = changedText
        }
        
        // Create Headers
        
        let createHeader: ((String) -> ViewFormer) = { text in
            return LabelViewFormer<FormLabelHeaderView>()
                .configure {
                    $0.viewHeight = 40
                    $0.text = text
            }
        }
        
        // Create SectionFormers
        
        let imageSection = SectionFormer(rowFormer: imageRow)
            .set(headerViewFormer: createHeader("Profile Image"))
        let introductionSection = SectionFormer(rowFormer: introductionRow)
            .set(headerViewFormer: createHeader("Introduction"))
        let aboutSection = SectionFormer(rowFormer: nameRow, birthdayRow)
            .set(headerViewFormer: createHeader("About"))
        
        former.append(sectionFormer: imageSection, introductionSection, aboutSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
        former.append(sectionFormer: informationSection)
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { 
            
        }
        let image = info[UIImagePickerControllerEditedImage]
        imageRow.cellUpdate { cell in
            is_changed = true
            is_photo_changed = true
            Me.img_avatar = image as? UIImage
            cell.iconView.image = image as! UIImage?
            
        }
    }
}
