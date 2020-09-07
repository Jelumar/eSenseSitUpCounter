//
//  Loading.swift
//  TestBluetooth
//
//  Created by Jean Baumgarten on 23.08.20.
//  Copyright © 2020 Jean Baumgarten. All rights reserved.
//

import SwiftUI

struct Loading: View {
    @State private var pulsate = false
    
    var body: some View {
        Image("bt")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(pulsate ? 0.1 : 0.2)
            .animation(Animation.easeInOut(duration: 1)
                .delay(0)
                .repeatCount(Int.max, autoreverses: true))
                .onAppear() {
                    self.pulsate.toggle()
                }
    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        Loading()
    }
}
