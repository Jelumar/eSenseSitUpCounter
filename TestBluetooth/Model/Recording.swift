//
//  Recording.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 03.09.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import UIKit

class Recording {
    
//    private var xAcce: [Float] = []
//    private var yAcce: [Float] = []
//    private var zAcce: [Float] = []
    private var xGyro: [Float] = []
    private var yGyro: [Float] = []
    private var zGyro: [Float] = []
    
//    private var xAcceSlope: [Float] = []
//    private var yAcceSlope: [Float] = []
//    private var zAcceSlope: [Float] = []
    private var xGyroSlope: [Float] = []
    private var yGyroSlope: [Float] = []
    private var zGyroSlope: [Float] = []
    
    public func addValues(_ sensorData: SensorData) {
//        self.xAcce.append(sensorData.xAcce)
//        self.yAcce.append(sensorData.yAcce)
//        self.zAcce.append(sensorData.zAcce)
        self.xGyro.append(sensorData.xGyro)
        self.yGyro.append(sensorData.yGyro)
        self.zGyro.append(sensorData.zGyro)
        
//        self.xAcceSlope.append(Recording.calculateSlope(for: self.xAcce))
//        self.yAcceSlope.append(Recording.calculateSlope(for: self.yAcce))
//        self.zAcceSlope.append(Recording.calculateSlope(for: self.zAcce))
        self.xGyroSlope.append(Recording.calculateSlope(for: self.xGyro))
        self.yGyroSlope.append(Recording.calculateSlope(for: self.yGyro))
        self.zGyroSlope.append(Recording.calculateSlope(for: self.zGyro))
    }
    
    private static func calculateSlope(for values: [Float]) -> Float {
        if values.count == 1 {
            return 0
        }
        return values[values.count - 1] - values[values.count - 2]
    }
    
    public func saveToClipBoard() {
        var clipBoard: String = ""
//        clipBoard.append("\n")
//        for value in xAcce {
//            clipBoard.append("\(value),")
//        }
//        clipBoard.append("\n")
//        for value in yAcce {
//            clipBoard.append("\(value),")
//        }
//        clipBoard.append("\n")
//        for value in zAcce {
//            clipBoard.append("\(value),")
//        }
        clipBoard.append("\n")
        for value in xGyro {
            clipBoard.append("\(value),")
        }
        clipBoard.append("\n")
        for value in yGyro {
            clipBoard.append("\(value),")
        }
        clipBoard.append("\n")
        for value in zGyro {
            clipBoard.append("\(value),")
        }
        clipBoard.append("\n")
        UIPasteboard.general.string = clipBoard
    }
    
    public func getAmountOfSitUps() -> Int {
        let xEvaluation = self.getAmountOfSitUps(for: self.xGyroSlope)
        let yEvaluation = self.getAmountOfSitUps(for: self.yGyroSlope)
        let zEvaluation = self.getAmountOfSitUps(for: self.zGyroSlope)
        if xEvaluation == yEvaluation && yEvaluation == zEvaluation {
            return xEvaluation
        } else if distanceIsSmall(between: xEvaluation, yEvaluation, and: zEvaluation) {
            return xEvaluation
        } else {
            return (xEvaluation * 70 + yEvaluation * 25 + zEvaluation * 5) / 100
        }
    }
    
    private func distanceIsSmall(between x: Int, _ y: Int, and z: Int, with distance: Int = 1) -> Bool {
        return abs(x - y) <= distance && abs(x - z) <= distance * 2
    }
    
    private func getAmountOfSitUps(for slope: [Float]) -> Int {
        if slope.count > 0 {
            var up: [Int8] = []
            for i in 0 ..< slope.count {
                up.append(verifyNeighborhood(for: slope, at: i))
            }
            var typ: [Int8] = []
            var amount: [Int] = []
            typ.append(up[0])
            amount.append(1)
            for i in 1 ..< up.count {
                if up[i] != 0 {
                    if typ[typ.count - 1] == up[i] {
                        amount[amount.count - 1] += 1
                    } else {
                        typ.append(up[i])
                        amount.append(1)
                    }
                }
            }
            let average = amount.average()
            var sitUpCount: Int = 0
            for a in amount {
                if a > (average * 2 / 3) {
                    sitUpCount += 1
                }
            }
            sitUpCount /= 2
            return sitUpCount
        } else {
            return 0
        }
    }
    
    private func verifyNeighborhood(for array: [Float], at position: Int, withRange range: Int = 2, andTolerance tolerance: Int = 1) -> Int8 {
        var increase = 0
        var decrease = 0
        for i in (position - range) ... (position + range) {
            if i >= 0 && i < array.count {
                if array[i] >= 0 {
                    increase += 1
                } else {
                    decrease += 1
                }
            }
        }
        if increase <= tolerance {
            return -1
        } else if decrease <= tolerance {
            return 1
        } else {
            return 0
        }
    }
    
}
