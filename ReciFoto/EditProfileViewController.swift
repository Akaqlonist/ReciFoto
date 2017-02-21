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
        let nicknameRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Username"
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Your Username"
//                $0.text = Profile.sharedInstance.nickname
            }.onTextChanged {_ in
//                Profile.sharedInstance.nickname = $0
        }
        
        let phoneRow = TextFieldRowFormer<ProfileFieldCell>(instantiateType: .Nib(nibName: "ProfileFieldCell")) { [weak self] in
            $0.titleLabel.text = "Phone"
            $0.textField.keyboardType = .numberPad
            $0.textField.inputAccessoryView = self?.formerInputAccessoryView
            }.configure {
                $0.placeholder = "Add your phone number"
//                $0.text = Profile.sharedInstance.phoneNumber
            }.onTextChanged {_ in
//                Profile.sharedInstance.phoneNumber = $0
        }
        return SectionFormer(rowFormer: nicknameRow, phoneRow)
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
//                $0.text = Profile.sharedInstance.name
            }.onTextChanged {_ in
//                Profile.sharedInstance.name = $0
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
//                $0.text = Profile.sharedInstance.introduction
            }.onTextChanged {_ in
//                Profile.sharedInstance.introduction = $0
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
//        let moreSection = SectionFormer(rowFormer: moreRow)
//            .set(headerViewFormer: createHeader("More Infomation"))
        
        former.append(sectionFormer: imageSection, introductionSection, aboutSection)
            .onCellSelected { [weak self] _ in
                self?.formerInputAccessoryView.update()
        }
//        if Profile.sharedInstance.moreInformation {
            former.append(sectionFormer: informationSection)
//        }
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    private func switchInfomationSection() {
//        if Profile.sharedInstance.moreInformation {
//            former.insertUpdate(sectionFormer: informationSection, toSection: former.numberOfSections, rowAnimation: .top)
//        } else {
//            former.removeUpdate(sectionFormer: informationSection, rowAnimation: .top)
//        }
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
