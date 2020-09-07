//
//  Extensions.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 23.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import Foundation
import SwiftUI

extension String: Identifiable {
    public var id: String {
        return self
    }
}

extension Sequence where Element: AdditiveArithmetic {
    // Returns the total sum of all elements in the sequence
    func sum() -> Element { reduce(.zero, +) }
}

extension Collection where Element: BinaryInteger {
    // Returns the average of all elements in the array
    func average() -> Element { isEmpty ? .zero : sum() / Element(count) }
    // Returns the average of all elements in the array as Floating Point type
    //func average<T: FloatingPoint>() -> T { isEmpty ? .zero : T(sum()) / T(count) }
}

extension Path {
    static func lineChart(points:[Float], step:CGPoint) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        guard let offset = points.min() else { return path }
        let p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
        path.move(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            path.addLine(to: p2)
        }
        return path
    }
}
