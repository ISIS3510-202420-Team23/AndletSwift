import SwiftUI

struct CustomButton: View {
    var title: String
    var action: () -> Void
    var isPrimary: Bool

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .foregroundColor(isPrimary ? .white : Color(red: 12/255, green: 53/255, blue: 106/255))
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .background(isPrimary ? Color(red: 12/255, green: 53/255, blue: 106/255) : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: isPrimary ? 0 : 2))
                .cornerRadius(8)
        }
    }
}
