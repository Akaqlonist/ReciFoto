//
//  EditProfileViewController.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

final class EditProfileViewController: FormViewController {
    
    // MARK: Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: Private
    
    private lazy var formerInputAccessoryView: FormerInputAccessoryView = FormerInputAccessoryView(former: self.former)
    
    fileprivate lazy var imageRow: LabelRowFormer<ProfileImageCell> = {
        LabelRowFormer<ProfileImageCell>(instantiateType: .Nib(nibName: "ProfileImageCell") , cellSetup: { imageCell in
            
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
            }.onTextChanged {_ in
//                Me.user.userName = $0.text
        }
        
        let phoneRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Phone"
            $0.textField.keyboardType = .numberPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your phone number"
                $0.text = Me.user.userPhone
            }.onTextChanged {_ in
//                Me.user.userPhone = $0.text
        }
        return SectionFormer(rowFormer: usernameRow, phoneRow)
    }()
    
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
                $0.text = Me.user.userName
            }.onTextChanged {_ in
//                Me.user.userFullName = $0.text
        }
        
        let birthdayRow = InlineDatePickerRowFormer<ProfileLabelCell>(instantiateType: .Nib(nibName: "ProfileLabelCell")) {
            $0.titleLabel.text = "Birthday"
            }.configure {_ in
//                $0.date = Profile.sharedInstance.birthDay ?? Date()
            }.inlineCellSetup {
                $0.datePicker.datePickerMode = .date
            }.displayTextFromDate {
                return String.mediumDateNoTime(date: $0)
            }.onDateChanged {_ in 
//                Profile.sharedInstance.birthDay = $0
        }
        let introductionRow = TextViewRowFormer<FormTextViewCell>() { [weak self] in
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            $0.textView.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your self-introduction"
                $0.text = Me.user.userBio
            }.onTextChanged {_ in
//                Me.user.userBio = $0.text
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
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
//        Profile.sharedInstance.image = image
        imageRow.cellUpdate {
            $0.iconView.image = image
        }
    }
}
