import SwiftUI

struct OfferImageCarouselView: View {
    let property: PropertyModel
    @State private var images: [UIImage?] = []
    
    var body: some View {
        TabView {
            if images.isEmpty {
                // Placeholder cuando no hay imágenes
                Text("No images available")
            } else {
                ForEach(Array(images.enumerated()), id: \.0) { index, image in
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // Placeholder mientras se carga la imagen
                        ProgressView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .onAppear {
            loadImages()
        }
    }
    
    func loadImages() {
        var tempImages: [UIImage?] = Array(repeating: nil, count: property.photos.count)
        
        for (index, photo) in property.photos.enumerated() {
            ImageCacheManager.shared.getImage(forKey: photo) { image in
                DispatchQueue.main.async {
                    tempImages[index] = image
                    self.images = tempImages
                }
            }
        }
    }
}
