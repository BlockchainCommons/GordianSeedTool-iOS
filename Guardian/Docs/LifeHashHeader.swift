//
//  LifeHashHeader.swift
//  Guardian
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI
import LifeHash
import Combine

struct LifeHashHeader: View {
    @StateObject var lifeHashState = LifeHashState(version: .version2, generateAsync: false)
    @State var seed: Seed?
    let publisher: AnyPublisher<Date, Never>
    
    init() {
        self.publisher = Timer.TimerPublisher.init(interval: 3.0, runLoop: .main, mode: .default).autoconnect().eraseToAnyPublisher()
        updateSeed()
    }
    
    var body: some View {
        VStack {
            LifeHashView(state: lifeHashState) {
                Rectangle()
                    .fill(Color.gray)
            }
            .frame(height: 100)
            
            Text(seed?.hex ?? "")
                .monospaced()
        }
        .onAppear {
            updateSeed()
        }
        .onReceive(publisher) { _ in
            updateSeed()
        }
    }
    
    func updateSeed() {
        seed = Seed()
        lifeHashState.input = seed
    }
}

#if DEBUG

struct LifeHashHeader_Previews: PreviewProvider {
    static var previews: some View {
        LifeHashHeader()
            .darkMode()
    }
}

#endif
