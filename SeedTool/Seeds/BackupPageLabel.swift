import SwiftUI

struct BackupPageLabel: View {
    let title: Text
    let icon: Image
    
    var body: some View {
        Label(title: { title }, icon: { icon })
            .font(.system(size: 16, weight: .bold))
    }
}

#if DEBUG

#Preview(
    traits: .fixedLayout(width: 500, height: 500)
) {
    BackupPageLabel(title: Text("Title"), icon: Image.bitcoin)
        .padding()
        .lightMode()
}

#endif
