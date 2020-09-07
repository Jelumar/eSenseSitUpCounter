//
//  ContentView.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 06.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var earable: Earable
    
    var body: some View {
        VStack(alignment: .center) {
            if Settings.isDeviceAddedForAutoConnect() || earable.connected{
                DeviceView(name: Settings.autoConnectToDevice(), earable: earable, viewCameUp: false, autoConnect: true)
            } else {
                if earable.areEarbudsFound() {
                    DeviceList(earable: earable)
                } else {
                    LoadingDevices(earable: earable)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(earable: Earable())
    }
}
