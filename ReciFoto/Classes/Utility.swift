//
//  Utility.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/27/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
open class Utility : NSObject  {
    static let sharedInstance : Utility = {
        let instance = Utility()
        return instance
    }()
    
    public override init() {
        super.init()
    }
    func dateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    func stringToDate(str: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if str == "" || str == "0000-00-00"{
            return Date()
        }else{
            return dateFormatter.date(from: str)!
        }
    }
}
