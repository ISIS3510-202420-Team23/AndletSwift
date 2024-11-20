import SwiftUI

struct CustomFeedbackInputField: View {
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int
    var height: CGFloat
    var cornerRadius: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            ZStack(alignment: .topLeading) {
                // TextEditor
                TextEditor(text: $text)
                    .padding()
                    .frame(height: height)
                    .background(Color.white)
                    .cornerRadius(cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.black, lineWidth: 1)) // Borde negro más delgado
                    .onChange(of: text) { _, newValue in
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }

                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.black) // Placeholder negro
                        .padding(.horizontal, 15)
                        .padding(.vertical, 12)
                        .font(.custom("Montserrat-ExtraLightItalic", size: 12))
                        .allowsHitTesting(false)
                }
            }

            HStack {
                // Contador de caracteres alineado a la izquierda y negro
                Text("\(text.count)/\(maxCharacters)")
                    .font(.footnote)
                    .foregroundColor(text.count > maxCharacters ? .red : .black)

                Spacer()

                // Botón de envío más delgado verticalmente
                Button(action: {
                    print("Feedback submitted: \(text)")
                    text = ""
                }) {
                    Text("Submit")
                        .font(.custom("Montserrat-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.vertical, 6) // Más delgado verticalmente
                        .padding(.horizontal, 16)
                        .background(Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255))
                        .cornerRadius(8)
                }
            }
        }
    }
}
