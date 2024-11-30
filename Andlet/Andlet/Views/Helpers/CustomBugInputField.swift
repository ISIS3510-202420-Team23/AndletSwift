import SwiftUI

struct CustomBugInputField: View {
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat
    var cornerRadius: CGFloat
    var onSubmit: (String) -> Void

    @Binding var notificationMessage: String?
    @Binding var notificationColor: Color?
    var isConnected: Bool // Estado de la conexión a Internet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .padding()
                    .frame(height: height)
                    .background(Color.white)
                    .cornerRadius(cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.black, lineWidth: 1))
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }

                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-ExtraLightItalic", size: 12))
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Text("\(text.count)/\(maxCharacters)")
                    .font(.footnote)
                    .foregroundColor(text.count > maxCharacters ? .red : .black)

                Spacer()

                Button(action: {
                    if !isConnected {
                        // Mostrar advertencia de conexión a Internet
                        withAnimation {
                            notificationMessage = "⚠️ No Internet Connection, you cannot submit a bug report while you are offline."
                            notificationColor = .orange
                        }
                        return
                    }

                    let cleanedText = text.removingExtraSpaces()
                    if cleanedText.isEmpty {
                        // Notificación de texto vacío
                        withAnimation {
                            notificationMessage = "Bug cannot be empty. Please write something."
                            notificationColor = .red.opacity(0.8)
                        }
                    } else if cleanedText.containsEmoji {
                        // Notificación de emojis
                        withAnimation {
                            notificationMessage = "Please remove any emojis from the bug."
                            notificationColor = .red.opacity(0.8)
                        }
                    } else {
                        onSubmit(cleanedText)
                    }
                }) {
                    Text("Submit")
                        .font(.custom("Montserrat-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255))
                        .cornerRadius(8)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}
