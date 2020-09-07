//
//  Structs.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 25.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Services {
    static let EarableService: CBUUID = CBUUID(string: "0xFF06")
    static let NameService: CBUUID = CBUUID(string: "0x1800")
}

struct Characteristics {
    static let IMUSampling: CBUUID = CBUUID(string: "0xFF07")
    static let SensorData: CBUUID = CBUUID(string: "0xFF08")
    static let ButtonStatus: CBUUID = CBUUID(string: "0xFF09")
    static let BatteryVoltage: CBUUID = CBUUID(string: "0xFF0A")
    static let ConnectionInterval: CBUUID = CBUUID(string: "0xFF0B")
    static let AccelerometerOffset: CBUUID = CBUUID(string: "0xFF0D")
    static let IMUScaleRange: CBUUID = CBUUID(string: "0xFF0E")
    static let DeviceName: CBUUID = CBUUID(string: "0x2A00")
}

struct SensorData {
    var xAcce: Float = 0
    var yAcce: Float = 0
    var zAcce: Float = 0
    var xGyro: Float = 0
    var yGyro: Float = 0
    var zGyro: Float = 0
}
