//
//  DeviceList.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 23.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct DeviceList: View {
    @ObservedObject var earable: Earable
    var body: some View {
        NavigationView {
            List {
                ForEach(earable.allEarbudsByName, id: \.id) { name in
                    NavigationLink(destination: DeviceView(name: name,earable: self.earable, viewCameUp: true, autoConnect: false)) {
                        Text(name)
                    }
                }
            }.navigationBarTitle("Devices")
        }
    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DeviceList(earable: Earable())
    }
}
