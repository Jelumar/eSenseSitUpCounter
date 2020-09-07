//
//  Loading.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 22.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct LoadingDevices: View {
    @ObservedObject var earable: Earable
    
    var body: some View {
        VStack {
            Spacer()
            Loading()
            Text(earable.BLEStatusInfo)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
}

struct LoadingDevices_Previews: PreviewProvider {
    static var previews: some View {
        LoadingDevices(earable: Earable())
    }
}
