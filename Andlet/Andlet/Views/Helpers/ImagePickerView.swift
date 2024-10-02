import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 255/255, green: 244/255, blue: 207/255))
                .frame(width: 140, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
                )

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 80)
                    .clipped()
            } else {
                Text("+")
                    .font(.largeTitle)
                    .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
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
