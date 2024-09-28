//
//  OfferRentView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 17/09/24.

import SwiftUI
import FirebaseFirestore

struct OfferRentView: View {
    let offer: OfferModel
    let property: PropertyModel
    
    @State private var isSold = false
    
    // Iniciamos el estado con el valor de is_active (disponible o vendido)
    init(offer: OfferModel, property: PropertyModel) {
        self.offer = offer
        self.property = property
        _isSold = State(initialValue: !offer.isActive)  // Si no está activo, se considera vendido
    }
    
    var body: some View{
        VStack(spacing: 8){
//            images
            OfferImageCarouselView()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .tabViewStyle(.page)
//            listing details
            
            VStack(alignment: .leading) {
                
                // Información de la propiedad
                Text(property.title)
                    .font(.custom("LeagueSpartan-SemiBold", size: 16))
                    .padding(.top, 5)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color(hex: "000000"))
                    Text(property.address)
                        .font(.custom("LeagueSpartan-ExtraLight", size: 16))
                        .foregroundColor(Color(hex: "000000"))
                }
                .foregroundColor(.gray)
                
                HStack {
                    Text("\(offer.numBeds) 🛏 ")
                        .foregroundColor(Color(hex: "000000"))
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                    Text("|")
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                            .foregroundColor(Color(hex: "000000"))
                    Text("\(offer.numBaths) 🛁")
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "000000"))
                    Text("|")
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                            .foregroundColor(Color(hex: "000000"))
                    Text("\(offer.roommates) 🧑‍🤝‍🧑")
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "000000"))
                    Spacer() // Este Spacer empuja el precio hacia la derecha
                    Text("$\(offer.pricePerMonth, specifier: "%.0f")")
                        .font(.custom("LeagueSpartan-SemiBold", size: 17))
                        .foregroundColor(Color(hex: "000000"))
                }
                .foregroundColor(.black)
                
                HStack {
                    // Views and bookmarks
                    Text("15 views")
                        .font(.custom("LeagueSpartan-Light", size: 16))

                        .foregroundColor(.black)
                    
//                    Text("•")
//                        .font(.custom("LeagueSpartan-Light", size: 16))
//                        .foregroundColor(.black)
//
//                    Text("2 bookmarks")
//                        .font(.custom("LeagueSpartan-Light", size: 16))
//                        .foregroundColor(.black)
                        
                    
                    Spacer()
                    
                    // Sold status
                    HStack(spacing: 4) {
                        // Circle changes based on sold status
                        Circle()
                            .stroke(isSold ? Color.clear : Color.black, lineWidth: 1) // Outline when available
                            .background(isSold ? Circle().foregroundColor(.black) : nil) // Filled when sold
                            .frame(width: 16, height: 16)

                        // Button to toggle between "Available" and "Sold"
                        Button(action: {
                            isSold.toggle() // Toggle the state
                            updateOfferStatusInFirestore()
                        }) {
                            Text(isSold ? "Sold" : "Available") // Change label based on state
                                .font(.custom("LeagueSpartan-Medium", size: 16))
                                .foregroundColor(.black)
                        }
                    }
}
                .padding(.top, -5)
                
               
            }
            .padding(.horizontal, 8)
            
        }
        .padding()
        
    }
    // Función para actualizar el campo is_active en Firestore
        func updateOfferStatusInFirestore() {
            print(offer.id)
            guard let offerId = offer.id else {
                print("No se encontró el id de la oferta")
                return
            }
            
            // Aquí separamos el document ID y el campo de la oferta
            let parts = offerId.split(separator: "_")
            if parts.count == 2 {
                let documentId = String(parts[0])
                let fieldId = String(parts[1])
                
                let db = Firestore.firestore()
                
                // Cambiar el campo is_active a su valor opuesto
                print(offer.id)
                db.collection("offers").document(documentId).updateData([
                    "\(fieldId).is_active": !offer.isActive  // Cambia el valor
                ]) { error in
                    if let error = error {
                        print("Error al actualizar el estado de la oferta: \(error)")
                    } else {
                        print("El estado de la oferta ha sido actualizado con éxito.")
                    }
                }
            } else {
                print("El ID de la oferta no está en el formato esperado")
            }
        }
    }
//#Preview {
//    OfferRentView(
//        offer: OfferModel(
//            finalDate: Date(),
//            idProperty: "1",
//            initialDate: Date(),
//            isActive: true,
//            numBaths: 1,
//            numBeds: 4,
//            numRooms: 4,
//            onlyAndes: true,
//            pricePerMonth: 1500000,
//            roommates: 0,
//            type: .entirePlace,
//            userId: "tamaiothais@gmail.com"
//        ),
//        property: PropertyModel(
//            address: "Ac. 19 #2a - 10, Bogotá",
//            complexName: "City U",
//            description: "Spacious apartment with modern amenities.",
//            location: [4.6037, -74.0683],
//            photos: [],
//            title: "Apartment - T2 - 1102"
//        )
//    )
//}
