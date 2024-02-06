import SwiftUI
import WolfBase

struct BackupPageSection<Content>: View where Content: View {
    let title: Text
    let icon: Image
    let content: () -> Content
    
    init(title: Text, icon: Image, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            BackupPageLabel(title: title, icon: icon)
            content()
        }
    }
}

#if DEBUG

import WolfLorem

#Preview(
    traits: .fixedLayout(width: pointsPerInch * 8.5, height: pointsPerInch * 11.5)
) {
    BackupPageSection(title: Text(Lorem.title()), icon: Image.bitcoin) {
        Text(Lorem.paragraph())
    }
    .padding()
    .lightMode()
}

#endif
