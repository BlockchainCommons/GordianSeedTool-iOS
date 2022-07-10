//
//  URHeader.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI
import URUI
import Combine
import BCApp

struct URHeader: View {
    @State var seed: ModelSeed = ModelSeed()
    let publisher: AnyPublisher<Date, Never>
    
    init() {
        self.publisher = Timer.TimerPublisher.init(interval: 3.0, runLoop: .main, mode: .default).autoconnect().eraseToAnyPublisher()
        updateSeed()
    }
    
    var body: some View {
        let data = Binding<Data>(
            get: { seed.qrData },
            set: { _ in }
        )
        VStack {
            URQRCode(data: data)
                .frame(height: 100)
            
            Text(seed.urString)
                .appMonospaced()
                .fixedVertical()
        }
        .onAppear {
            updateSeed()
        }
        .onReceive(publisher) { _ in
            updateSeed()
        }
    }
    
    func updateSeed() {
        let seed = ModelSeed()
        seed.name = ""
        self.seed = seed
    }
}

#if DEBUG

struct URHeader_Previews: PreviewProvider {
    static var previews: some View {
        URHeader()
            .darkMode()
    }
}

#endif
