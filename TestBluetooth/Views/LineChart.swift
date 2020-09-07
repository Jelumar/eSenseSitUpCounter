//
//  LineChart.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 07.09.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct LineChart: View {
    var data: [Float]
    let title: String = "Last Workout:"
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                Text(self.title)
                    .font(.title)
                    .padding()
                ZStack{
                    GeometryReader{ reader in
                        Line(data: self.data, frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width , height: reader.frame(in: .local).height)))
                            .offset(x: 0, y: 0)
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 200)
                    .offset(x: 0, y: 0)

                }
                .frame(width: geometry.frame(in: .local).size.width, height: 200)
        
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: [])
    }
}
