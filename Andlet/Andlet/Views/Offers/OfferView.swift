//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI

struct OfferView: View {
    let offer: OfferModel
    let property: PropertyModel
    
    var body: some View{
        VStack(spacing: 8){
//            images
            OfferImageCarouselView(property: property)
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
                
               
            }
            .padding(.horizontal, 8)
            
        }
        .padding()
    }
}
//#Preview {
//    OfferView()
//}
