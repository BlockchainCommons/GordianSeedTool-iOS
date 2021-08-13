//
//  BIP39Header.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/12/21.
//

import SwiftUI
import Combine

struct BIP39Header: View {
    @State var seed: Seed = Seed()
    let publisher: AnyPublisher<Date, Never>
    
    init() {
        self.publisher = Timer.TimerPublisher.init(interval: 3.0, runLoop: .main, mode: .default).autoconnect().eraseToAnyPublisher()
        updateSeed()
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image("39.bar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            
            VStack {
                Text(seed.bip39)
                    .monospaced()
                    .fixedVertical()
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            updateSeed()
        }
        .onReceive(publisher) { _ in
            updateSeed()
        }
    }
    
    func updateSeed() {
        let seed = Seed()
        seed.name = ""
        self.seed = seed
    }
}

#if DEBUG

struct BIP39Header_Previews: PreviewProvider {
    static var previews: some View {
        BIP39Header()
            .darkMode()
    }
}

#endif
