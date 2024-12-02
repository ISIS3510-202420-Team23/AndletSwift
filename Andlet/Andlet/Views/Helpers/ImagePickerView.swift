import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool

    var body: some View {
        ZStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 80)
                    .clipped()
                    .cornerRadius(10) // Aplica el redondeo directamente a la imagen
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 255/255, green: 244/255, blue: 207/255))
                    .frame(width: 140, height: 80)
                    .overlay(
                        Text("+")
                            .font(.largeTitle)
                            .foregroundColor(primaryColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(primaryColor, lineWidth: 2)
                    )
            }
        }
        .onTapGesture {
            showImagePicker.toggle()  // Solo se abrirá cuando se toque dentro del recuadro
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .contentShape(Rectangle()) // Asegura que la zona de tap es solo la del recuadro
    }
}
