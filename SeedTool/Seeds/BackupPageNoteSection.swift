import SwiftUI

struct BackupPageNoteSection: View {
    let note: String
    
    var body: some View {
        BackupPageSection(title: Text("Notes"), icon: Image.note) {
            Text(note)
                .font(.system(size: backupPageTextFontSize))
                .minimumScaleFactor(0.3)
        }
    }
}

#if DEBUG

import WolfLorem

#Preview(
    traits: .fixedLayout(width: 500, height: 500)
) {
    BackupPageNoteSection(note: Lorem.paragraph())
        .padding()
        .lightMode()
}

#endif
