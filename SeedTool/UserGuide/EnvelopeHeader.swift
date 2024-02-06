import SwiftUI
import Combine
import BCApp

struct EnvelopeHeader: View {
    @State var seed: ModelSeed = ModelSeed()
    let publisher: AnyPublisher<Date, Never>
    
    init() {
        self.publisher = Timer.TimerPublisher.init(interval: 3.0, runLoop: .main, mode: .default).autoconnect().eraseToAnyPublisher()
        updateSeed()
    }
    
    var body: some View {
        let data = Binding<Data>(
            get: { seed.envelope.ur.qrData },
            set: { _ in }
        )
        VStack {
            HStack {
                Image.envelope
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                URQRCode(data: data, foregroundColor: .black, backgroundColor: .white)
                    .frame(height: 100)
            }
            
            Text(seed.envelope.urString)
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

struct EnvelopeHeader_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeHeader()
            .darkMode()
    }
}

#endif
