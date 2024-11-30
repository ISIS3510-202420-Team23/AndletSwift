import SwiftUI

struct CustomButton: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    var title: String
    var action: () -> Void
    var isPrimary: Bool

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .foregroundColor(isPrimary ? .white : primaryColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .background(isPrimary ? primaryColor : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(primaryColor, lineWidth: isPrimary ? 0 : 2))
                .cornerRadius(8)
        }
    }
}
