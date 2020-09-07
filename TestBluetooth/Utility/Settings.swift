//
//  Settings.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 06.09.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import Foundation

class Settings {
    
    public static func startWith(device name: String) {
        UserDefaults.standard.set(name, forKey: "eSenseName")
    }
    
    public static func startWithNoDevice() {
        UserDefaults.standard.removeObject(forKey: "eSenseName")
    }
    
    public static func isDeviceAddedForAutoConnect() -> Bool {
        return Settings.autoConnectToDevice() != ""
    }
    
    public static func autoConnectToDevice() -> String {
        if let deviceName = UserDefaults.standard.string(forKey: "eSenseName") {
            return deviceName
        }
        return ""
    }
    
}
