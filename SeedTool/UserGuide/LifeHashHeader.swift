//
//  LifeHashHeader.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI
import Combine
import BCApp

struct LifeHashHeader: View {
    @StateObject var lifeHashState = LifeHashState(version: .version2, generateAsync: false)
    @State var seed: ModelSeed?
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
                .appMonospaced()
        }
        .onAppear {
            updateSeed()
        }
        .onReceive(publisher) { _ in
            updateSeed()
        }
    }
    
    func updateSeed() {
        seed = ModelSeed()
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
