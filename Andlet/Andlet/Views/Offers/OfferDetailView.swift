import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OfferDetailView: View {
    
    @State private var showContactDetails = false
    @State private var navigateBackToMainTab = false  // New state to manage navigation back
    
    let offer: OfferModel
    let property: PropertyModel
    
    @StateObject private var viewModel = OfferDetailViewModel()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView {
                ZStack (alignment: .topLeading) {
                    OfferImageCarouselView(property: property)
                        .frame(height: 370)
                        .tabViewStyle(.page)
                    
                    // Button to navigate back to MainTabView
                    NavigationLink(destination: MainTabView(), isActive: $navigateBackToMainTab) {
                        EmptyView() // Invisible NavigationLink
                    }
                    
                    Button {
                        navigateBackToMainTab = true  // Trigger navigation to MainTabView
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(hex: "FFF4CF"))
                            .background {
                                Circle()
                                    .fill(Color(hex: "0C356A"))
                                    .frame(width: 40, height: 40)
                            }
                            .padding(32)
                            .padding(.top, 30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(property.title)
                        .font(.custom("LeagueSpartan-SemiBold", size: 28))
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(Color(hex: "000000"))
                        Text(property.address)
                            .font(.custom("LeagueSpartan-ExtraLight", size: 17))
                            .foregroundColor(Color(hex: "000000"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading)
                .padding(.top)
                .padding(.bottom, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text ("Facilities")
                        .font(.custom("LeagueSpartan-SemiBold", size: 22))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: "bed.double")
                                Text("\(offer.numBeds) Bedrooms")
                                    .font(.custom("LeagueSpartan-Regular", size: 19))
                            }
                            .frame(width: 130, height: 80)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(Color(hex: "CFCFCF"))
                            }
                            
                            VStack {
                                Image(systemName: "shower")
                                Text("\(offer.numBaths) Bathrooms")
                                    .font(.custom("LeagueSpartan-Regular", size: 19))
                            }
                            .frame(width: 132, height: 85)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(Color(hex: "CFCFCF"))
                            }
                            
                            VStack {
                                Image(systemName: "person.2")
                                Text("\(offer.roommates) Roommates")
                                    .font(.custom("LeagueSpartan-Regular", size: 19))
                            }
                            .frame(width: 132, height: 85)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(Color(hex: "CFCFCF"))
                            }
                        }
                    }
                }
                .padding(.leading)
                .padding(.top, 7)
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.custom("LeagueSpartan-SemiBold", size: 22))
                        .frame(width: 250, alignment: .leading )
                    
                    Text(property.description)
                        .font(.custom("LeagueSpartan-Light", size: 17))
                        .padding(.top, 1)
                    
                }
                .padding(.top)
                .padding(.leading)
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea()
            .padding(.bottom, 64)
            .overlay(alignment: .bottom) {
                VStack (spacing: 0) {
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        
                        
                        if let photoURL = URL(string: viewModel.user.photo), !viewModel.user.photo.isEmpty {
                            AsyncImage(url: photoURL) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 55, height: 55)
                            }
                        } else {
                            Image("Icon")  // Imagen predeterminada
                                .resizable()
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading) {
//                            if viewModel.isLoading {
//                                Text("Loading...")
//                                    .font(.custom("LeagueSpartan-SemiBold", size: 18))
//                                    .foregroundColor(Color(hex: "0C356A"))
//                            } else {
                                Text(viewModel.user.name)
                                    .font(.custom("LeagueSpartan-SemiBold", size: 18))
                                    .foregroundColor(Color(hex: "0C356A"))
//                            }
                            Text("Property agent")
                                .font(.custom("LeagueSpartan-SemiBold", size: 18))
                                .foregroundColor(Color(hex: "3D4D62"))
                            Text("$\(offer.pricePerMonth, specifier: "%.0f")")
                                .font(.custom("LeagueSpartan-Regular", size: 18))
                                .padding(.top, 4)
                        }
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showContactDetails.toggle()
                            }
                            logContactAction()  // Llamada a la función para registrar el evento en Firestore
                        } label: {
                            Text("Contact")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .frame(width: 140, height: 50)
                                .background(Color(hex: "0C356A"))
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                    }
                    .padding(.horizontal, 18)
                    
                    VStack {
                        if showContactDetails {
                            Text(offer.userId)
                                .font(.custom("LeagueSpartan-Regular", size: 18))
                                .padding(.top, 15)
                                .underline()
                                .foregroundColor(Color.blue)
                                .padding(.horizontal, 18)
                                .onTapGesture {
                                    openEmailClient(to: offer.userId)
                                }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
                .background(Color(hex: "FFF4CF"))
                .frame(maxHeight: showContactDetails ? nil : 50)
            }
            .onAppear {
                viewModel.fetchUser(userEmail: offer.userId)
                updateUserViewCount()
                let documentId = "E2amoJzmIbhtLq65ScpY"
                if let offerKey = offer.id.split(separator: "_").last.map(String.init) {
                    viewModel.updateViewsOffer(documentId: documentId, offerKey: offerKey)
                } else {
                    print("No se encontró un offerKey válido para la oferta")
                }
            }
        } else {
            Text("Versión de iOS no soportada")
        }
    }
    
    private func openEmailClient(to email: String) {
        
        let subject = "Interested in \(property.title) property"
        let body = "Hello \(viewModel.user.name),\n\nI would like to know more about the availability of the offer '\(property.title)' that you published on Andlet."
        
        // Codificamos los valores para que sean seguros en la URL
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Formatear la URL con el *mailto:*, el subject y el body
        let emailString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: emailString) {
            UIApplication.shared.open(url)
        } else {
            print("Error al intentar abrir el cliente de correo.")
        }
    }
    
    // Nueva función para registrar la acción de contacto en Firestore
    private func logContactAction() {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }
        
        // Crear un identificador único para el documento usando el formato solicitado
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let documentID = "2_\(userEmail)_\(formattedDate)"  // Identificador que empieza con "2"
        
        // Crear la estructura del documento
        let actionData: [String: Any] = [
            "action": "contact",
            "app": "swift",
            "date": Date(),
            "user_id": userEmail
        ]
        
        // Registrar la acción en la colección "user_actions" en Firestore
        let db = Firestore.firestore()
        db.collection("user_actions").document(documentID).setData(actionData) { error in
            if let error = error {
                print("Error al registrar el evento de contacto en Firestore: \(error.localizedDescription)")
            } else {
                print("Evento de contacto registrado exitosamente en Firestore con ID: \(documentID)")
            }
        }
    }
    
    func updateUserViewCount() {
        let db = Firestore.firestore()
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: No hay usuario logueado")
            return
        }
        
        // Documento en Firestore para las vistas del usuario
        let userViewsRef = db.collection("user_views").document(userEmail)
        
        userViewsRef.getDocument { document, error in
            if let document = document, document.exists {
                // Si el documento ya existe, actualizamos el contador correspondiente
                if offer.roommates > 0 {
                    userViewsRef.updateData([
                        "roommates_views": FieldValue.increment(Int64(1))
                    ]) { error in
                        if let error = error {
                            print("Error al actualizar roommates_views: \(error)")
                        } else {
                            print("roommates_views actualizado correctamente")
                        }
                    }
                } else {
                    userViewsRef.updateData([
                        "no_roommates_views": FieldValue.increment(Int64(1))
                    ]) { error in
                        if let error = error {
                            print("Error al actualizar no_roommates_views: \(error)")
                        } else {
                            print("no_roommates_views actualizado correctamente")
                        }
                    }
                }
            } else {
                // Si el documento no existe, lo creamos con los valores iniciales
                userViewsRef.setData([
                    "roommates_views": offer.roommates > 0 ? 1 : 0,
                    "no_roommates_views": offer.roommates > 0 ? 0 : 1
                ]) { error in
                    if let error = error {
                        print("Error al crear el documento de vistas del usuario: \(error)")
                    } else {
                        print("Documento de vistas del usuario creado correctamente")
                    }
                }
            }
        }
    }
}

//#Preview{
//    OfferDetailView()
//}
