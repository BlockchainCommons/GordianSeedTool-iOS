import SwiftUI

struct NoSeedSelected: View {
    var body: some View {
        VStack(spacing: 30) {
            Image.seed
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.accentColor)
            Text("Select a seed.")
                .bold()
        }
    }
}
