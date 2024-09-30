import SwiftUI

struct CustomTextField: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var maxCharacters: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.blue)
                .font(.custom("Montserrat-Light", size: 20))

            if #available(iOS 16.0, *) {
                // Usar `TextField` con `prompt` en iOS 16 o superior
                TextField("", text: $text, prompt: Text(placeholder))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                    .onChange(of: text) { oldValue, newValue in
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }
            } else {
                // Usar `TextField` con `placeholder` en versiones anteriores
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                    .onChange(of: text) { newValue in
                        if newValue.count > maxCharacters {
                            text = String(newValue.prefix(maxCharacters))
                        }
                    }
            }

            Text("\(text.count)/\(maxCharacters)")
                .font(.footnote)
                .foregroundColor(text.count > maxCharacters ? .red : .gray)
                .padding(.bottom, 5)
        }
    }
}
