//
//  DataPersistManger.swift
//  shop
//
//  Created by zhangle on 16/5/26.
//  Copyright © 2016年 DaDa Inc. All rights reserved.
//

import UIKit

class DataPersistManger: NSObject {
    
    lazy var userDefaults:UserDefaults = {
        let userDefaults = UserDefaults.standard
        return userDefaults
    }()
    
    func persistWithKeysArchive(_ dataObject:AnyObject?, key:String) {
        if let data = dataObject {
            let nsData:Data = NSKeyedArchiver.archivedData(withRootObject: data)
            self.userDefaults.set(nsData, forKey: key)
            self.userDefaults.synchronize()
        }
    }
    
    func getDataFromKeysArchive(_ key:String) -> AnyObject? {
        let data = self.userDefaults.object(forKey: key)
        if let dataObject = data {
            if (dataObject as AnyObject).isKind(of: NSData.classForCoder()) {
                return NSKeyedUnarchiver.unarchiveObject(with: (dataObject as! NSData) as Data) as AnyObject?
            }
            return dataObject as AnyObject?
        }
        return nil
    }
    
    func clearKey(_ key:String) {
        self.userDefaults.removeObject(forKey: key)
        self.userDefaults.synchronize()
    }

}
