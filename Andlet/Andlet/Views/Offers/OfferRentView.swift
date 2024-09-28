//
//  OfferRentView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 17/09/24.
//


import SwiftUI

struct OfferRentView: View {
    let offer: OfferModel
    let property: PropertyModel
    
    
    @State private var isSold: Bool
    @StateObject private var viewModel = OfferRentViewModel()
    
    // Inicializador que configura el estado basado en el campo `isActive` de la oferta
    init(offer: OfferModel, property: PropertyModel) {
        self.offer = offer
        self.property = property
        _isSold = State(initialValue: !offer.isActive)  // Si `isActive` es `false`, lo consideramos vendido
    }

    var body: some View {
        VStack(spacing: 8) {
            // Imagen de la propiedad
            OfferImageCarouselView()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .tabViewStyle(.page)

            // Información de la propiedad
            VStack(alignment: .leading) {
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
                    Spacer()
                    Text("$\(offer.pricePerMonth, specifier: "%.0f")")
                        .font(.custom("LeagueSpartan-SemiBold", size: 17))
                        .foregroundColor(Color(hex: "000000"))
                }
                .foregroundColor(.black)

                // Botón para cambiar entre "Available" y "Sold"
                HStack {
                    Text("15 views")
                        .font(.custom("LeagueSpartan-Light", size: 16))
                        .foregroundColor(.black)
                    
                    Spacer()

                    // Botón Sold/Available
                    HStack(spacing: 4) {
                        // Circulo que cambia en función de si está vendido o no
                        Circle()
                            .stroke(isSold ? Color.clear : Color.black, lineWidth: 1)
                            .background(isSold ? Circle().foregroundColor(.black) : nil)
                            .frame(width: 16, height: 16)

                        Button(action: {
                            isSold.toggle() 
                            
                            let offerKey = offer.id?.split(separator: "_").last.map(String.init) ?? "0"

                            
                            viewModel.toggleOfferAvailability(
                                documentId: "E2amoJzmIbhtLq65ScpY",
                                offerKey: offerKey,
                                newStatus: !isSold
                            )
                        }) {
                            Text(isSold ? "Sold" : "Available")
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
}
