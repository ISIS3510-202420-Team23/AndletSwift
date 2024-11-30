import SwiftUI

struct PriceField: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    var title: String
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat
    var cornerRadius: CGFloat
    var iconName: String

    @State private var formattedText: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(primaryColor)
                .font(.custom("Montserrat-Light", size: 20))

            HStack {
                Image(systemName: iconName)
                    .foregroundColor(primaryColor)
                    .padding(.leading, 10)

                TextField(placeholder, text: $formattedText)
                    .padding(.vertical, 12)
                    .font(.custom("Montserrat-SemiBold", size: 12))
                    .foregroundColor(primaryColor)
                    .keyboardType(.numberPad)
                    .onChange(of: formattedText) { oldValue, newValue in
                        let filteredValue = newValue.filter { $0.isNumber }
                        if filteredValue.count > maxCharacters {
                            formattedText = formatNumber(String(filteredValue.prefix(maxCharacters)))
                        } else {
                            formattedText = formatNumber(filteredValue)
                        }

                        if let numberValue = Int(filteredValue) {
                            text = String(numberValue)
                        } else {
                            text = "0"
                        }
                    }
            }
            .padding(.horizontal, 10)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(primaryColor, lineWidth: 2)
                    )
            )
        }
        .padding(.bottom, 60)
        .onAppear {
            formattedText = formatNumber(text)
        }
    }

    private func formatNumber(_ value: String) -> String {
        guard let number = Int(value) else { return value }

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."

        return numberFormatter.string(from: NSNumber(value: number)) ?? value
    }
}
