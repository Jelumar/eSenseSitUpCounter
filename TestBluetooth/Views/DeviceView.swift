//
//  DeviceView.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 23.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct DeviceView: View {
    let name: String
    @ObservedObject var earable: Earable
    @State var viewCameUp: Bool = true
    @State var autoConnect: Bool = false
    
    var body: some View {
        VStack {
            if viewCameUp {
                Button("Connect to \(name)") {
                    self.earable.selectAndConnectToEarbuds(withName: self.name)
                    self.viewCameUp.toggle()
                }
            } else {
                if earable.connected {
                    VStack {
                        Text("SitUps Done: \(earable.sitUps)")
                            .font(.largeTitle)
                            .padding()
                        //Text("GyroX : \(earable.sensorData.xGyro)")
                        LineChart(data: earable.chartData)
                        Spacer()
                        Form {
                            Button(earable.isRecording ? "End Workout" : "Start Workout") {
                                if self.earable.isRecording {
                                    self.earable.endRecording()
                                } else {
                                    self.earable.startRecording()
                                }
                            }
                            if !autoConnect {
                                Button("Disconnect Device") {
                                    self.earable.deactivateSampling()
                                    self.earable.disconnectPeripheral()
                                }.foregroundColor(.red)
                            }
                            Toggle(isOn: $autoConnect) {
                                Text("Automatically Connect")
                                if self.autoConnect {
                                    Text("\(autoConnectWith(device: earable.getSelectedEarbud().name ?? "Error"))")
                                } else {
                                    Text("\(noAutoConnect())")
                                }
                            }
                        }
                    }
                } else {
                    Loading()
                }
            }
        }
    }
    
    func autoConnectWith(device name: String) -> String {
        Settings.startWith(device: name)
        return ""
    }
    
    func noAutoConnect() -> String {
        Settings.startWithNoDevice()
        return ""
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(name: "Test", earable: Earable())
    }
}
