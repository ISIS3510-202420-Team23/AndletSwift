import SwiftUI

struct IncrementDecrementView: View {
    var title: String
    @Binding var count: Int
    var maxCount: Int // Limite máximo

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Montserrat-ExtraBold", size: 12))
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            HStack(spacing: 10) {
                Button(action: {
                    if count > 1 {
                        count -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
                        )
                }

                Text("\(max(count, 1))")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .frame(width: 40)

                Button(action: {
                    if count < maxCount { // No se permite incrementar más allá de `maxCount`
                        count += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2)
                        )
                }
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 5)
    }
}

// Preview del componente para probar su funcionamiento con diferentes valores iniciales
struct IncrementDecrementView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IncrementDecrementView(title: "Rooms available for sublet", count: .constant(1), maxCount: 5)
            IncrementDecrementView(title: "Beds", count: .constant(1), maxCount: 5)
            IncrementDecrementView(title: "Bathrooms", count: .constant(1), maxCount: 5)
        }
    }
}
