//
//  ByteWordsHeader.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI
import URUI
import Combine

struct ByteWordsHeader: View {
    @State var seed: ModelSeed = ModelSeed()
    let publisher: AnyPublisher<Date, Never>
    
    init() {
        self.publisher = Timer.TimerPublisher.init(interval: 3.0, runLoop: .main, mode: .default).autoconnect().eraseToAnyPublisher()
        updateSeed()
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image("bytewords.bar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            
            Text(seed.byteWords)
                .monospaced()
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

struct ByteWordsHeader_Previews: PreviewProvider {
    static var previews: some View {
        ByteWordsHeader()
            .darkMode()
    }
}

#endif
