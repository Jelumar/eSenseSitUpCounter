//
//  Earable.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 06.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import UIKit
import Combine
import CoreBluetooth

class Earable: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // eSense-0723
    
    private var centralManager: CBCentralManager!
    private var allPeripherals: [CBPeripheral] = []
    @Published var allEarbudsByName: [String] = [String]()
    private var allEarbuds: [String : CBPeripheral] = [:]
    private var selectedEarbuds: CBPeripheral!
    private var disconnectEarbuds: Bool = false
    private var samplingCharacteristic: CBCharacteristic?
    
    private var accScaleFactor: Float = 1.0
    private var gyroScaleFactor: Float = 1.0
    
    @Published var buttonStatus: Bool = false
    @Published var sensorData: SensorData = SensorData()
    @Published var connected: Bool = false
    @Published var BLEStatusInfo: String = "Bluetooth status is unknown..."
    
    @Published var isRecording: Bool = false
    private var recording: Recording = Recording()
    @Published var chartData: [Float] = []
    @Published var sitUps: Int = 0
    private var counterSitUpRecalculation: Int8 = 0
    
    func disconnectPeripheral() {
        self.disconnectEarbuds = true
        centralManager.cancelPeripheralConnection(self.selectedEarbuds)
    }
    
    func buttonChange(to value: Bool) {
        print("Button \(value ? "Pressed" : "Unpressed")")
        if value {
            if self.isRecording {
                self.endRecording()
            } else {
                self.startRecording()
            }
        }
    }
    
    func startRecording() {
        print("Start")
        self.sitUps = 0
        self.counterSitUpRecalculation = 0
        self.chartData = []
        self.isRecording = true
    }
    
    func precalculateSitUps() {
        if self.counterSitUpRecalculation >= 20 {
            self.counterSitUpRecalculation = 0
            self.sitUps = self.recording.getAmountOfSitUps()
        }
        self.counterSitUpRecalculation += 1
    }
    
    func endRecording() {
        print("End")
        self.sitUps = self.recording.getAmountOfSitUps()
        self.recording = Recording()
        self.isRecording = false
    }
    
    func getSelectedEarbud() -> CBPeripheral! {
        return self.selectedEarbuds
    }
    
    func areEarbudsFound() -> Bool {
        return allEarbuds.count > 0
    }
    
    func refresh() {
        allPeripherals = []
        allEarbudsByName = [String]()
        allEarbuds = [:]
        selectedEarbuds = nil
        connected = false
    }

    func selectAndConnectToEarbuds(withName name: String) {
        selectedEarbuds = allEarbuds[name]
        selectedEarbuds.delegate = self
        centralManager.stopScan()
        centralManager.connect(selectedEarbuds, options: nil)
    }
    
    func deactivateSampling() {
        if selectedEarbuds != nil && samplingCharacteristic != nil {
            let bytes: [UInt8] = [
                5 * 16 + 3,
                2, // checksum of last three
                2, // dataSize
                0, // OFF
                0  // sampleRate (Hz)
            ]
            let data: Data = Data(bytes)
            selectedEarbuds.writeValue(data, for: samplingCharacteristic!, type: .withResponse)
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            refresh()
            BLEStatusInfo = "Bluetooth status is unknown..."
        case .resetting:
            refresh()
            BLEStatusInfo = "Lost Bluetooth connection and resetting..."
        case .unsupported:
            refresh()
            BLEStatusInfo = "Bluetooth seams not to be supported by your Device..."
        case .unauthorized:
            refresh()
            BLEStatusInfo = "This App is not authorized to use Bleutooth, change settings to use the App..."
        case .poweredOff:
            refresh()
            BLEStatusInfo = "Turn on Bluetooth to search for Devices..."
        case .poweredOn:
            BLEStatusInfo = "Searching for compatible BLE Devices..."
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name: String = peripheral.name ?? "NonSense"
        if !allPeripherals.contains(peripheral) {
            allPeripherals.append(peripheral)
        }
        if name.starts(with: "eSense") {
            allEarbudsByName.append(name)
            allEarbuds[name] = peripheral
            if selectedEarbuds == nil {
                selectedEarbuds = peripheral
                selectedEarbuds.delegate = self
            }
            if Settings.autoConnectToDevice() == name {
                selectAndConnectToEarbuds(withName: name)
            }
        }
        allEarbudsByName.sort()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.selectedEarbuds {
            self.connected = true
            selectedEarbuds.discoverServices([Services.EarableService, Services.NameService])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from device")
        if self.disconnectEarbuds {
            self.disconnectEarbuds = false
            refresh()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            centralManager.connect(selectedEarbuds, options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == Services.EarableService {
                let chars: [CBUUID] = [
                    Characteristics.IMUSampling,
                    Characteristics.SensorData,
                    Characteristics.IMUScaleRange,
                    Characteristics.ButtonStatus,
                    Characteristics.BatteryVoltage
                ]
                peripheral.discoverCharacteristics(chars, for: service)
            } else if service.uuid == Services.NameService {
                print("Service: \(service)")
                peripheral.discoverCharacteristics([Characteristics.DeviceName], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            switch characteristic.uuid {
            case Characteristics.IMUSampling:
                samplingCharacteristic = characteristic
                let bytes: [UInt8] = [
                    5 * 16 + 3,
                    23, // checksum of last three
                    2, // dataSize
                    1, // ON
                    20  // sampleRate (Hz)
                ]
                let data: Data = Data(bytes)
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            case Characteristics.IMUScaleRange:
                peripheral.readValue(for: characteristic)
            case Characteristics.BatteryVoltage:
                peripheral.readValue(for: characteristic)
            case Characteristics.ButtonStatus:
                peripheral.setNotifyValue(true, for: characteristic)
            case Characteristics.SensorData:
                peripheral.setNotifyValue(true, for: characteristic)
            case Characteristics.DeviceName:
                peripheral.readValue(for: characteristic)
            default:
                print("No known Characteristic found")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == Characteristics.IMUSampling {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count == 5 {
                print("Sampling On: \(bytes[3]), Sampling Rate: \(bytes[4])")
            } else {
                print("Unexpected amount of data \(bytes.count) in Data for IMU Sampling")
            }
        }
        if characteristic.uuid == Characteristics.IMUScaleRange {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count == 7 {
                let gyroScaleFactors: [Float] = [131, 65.5, 32.8, 16.4]
                let accScaleFactors: [Float] = [16384, 8192, 4096, 2048]
                gyroScaleFactor = gyroScaleFactors[Int((bytes[4] & 0b00011000) >> 3)]
                accScaleFactor = accScaleFactors[Int((bytes[5] & 0b00011000) >> 3)]
            } else {
                print("Unexpected amount of data \(bytes.count) in Data for IMU Sampling")
            }
        }
        if characteristic.uuid == Characteristics.BatteryVoltage {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count == 6 {
                let voltage: Int = Int(bytes[3]) * 256 + Int(bytes[4])
                print("Battery Voltage: \(voltage), Charging: \(bytes[5])")
            } else {
                print("Unexpected amount of data \(bytes.count) in Data for Battery Voltage")
            }
        }
        if characteristic.uuid == Characteristics.ButtonStatus {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count == 4 {
                let buttonValue = bytes[3] == 1
                if buttonValue != buttonStatus {
                    self.buttonChange(to: buttonValue)
                    buttonStatus = buttonValue
                }
            } else {
                print("Unexpected amount of data \(bytes.count) in Data for Button Status")
            }
        }
        if characteristic.uuid == Characteristics.SensorData {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count == 16 {
                let accX: Int16 = Int16(bytes[4]) << 8 | Int16(bytes[5])
                let accY: Int16 = Int16(bytes[6]) << 8 | Int16(bytes[7])
                let accZ: Int16 = Int16(bytes[8]) << 8 | Int16(bytes[9])
                let gyroX: Int16 = Int16(bytes[10]) << 8 | Int16(bytes[11])
                let gyroY: Int16 = Int16(bytes[12]) << 8 | Int16(bytes[13])
                let gyroZ: Int16 = Int16(bytes[14]) << 8 | Int16(bytes[15])
                sensorData = SensorData(xAcce: Float(accX) / accScaleFactor,
                                        yAcce: Float(accY) / accScaleFactor,
                                        zAcce: Float(accZ) / accScaleFactor,
                                        xGyro: Float(gyroX) / gyroScaleFactor,
                                        yGyro: Float(gyroY) / gyroScaleFactor,
                                        zGyro: Float(gyroZ) / gyroScaleFactor)
                if self.isRecording {
                    self.recording.addValues(self.sensorData)
                    self.chartData.append(self.sensorData.xGyro)
                    self.precalculateSitUps()
                }
            } else {
                print("Unexpected amount of data \(bytes.count) in Data for Button Status")
            }
        }
        if characteristic.uuid == Characteristics.DeviceName {
            let data: Data = characteristic.value ?? Data()
            let bytes: [UInt8] = [UInt8](data)
            if bytes.count > 0 {
                print("Device Name is: \(String(bytes: bytes, encoding: .utf8) ?? "Error")")
            } else {
                print("Name is really short, \(bytes.count) bytes long to be exact...")
            }
        }
    }
    
}
