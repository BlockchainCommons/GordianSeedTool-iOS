import SwiftUI

@ViewBuilder
func groupTitle(_ title: String) -> some View {
    Text(title)
        .formGroupBoxTitleFont()
}
