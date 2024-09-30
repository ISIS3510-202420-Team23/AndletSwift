import SwiftUI

struct IncrementDecrementView: View {
    var title: String
    @Binding var count: Int // Valor ligado externamente

    var body: some View {
        HStack {
            // Texto a la izquierda
            Text(title)
                .font(.custom("Montserrat-ExtraBold", size: 12))
                .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Botones de decremento (-), número y incremento (+)
            HStack(spacing: 10) {
                Button(action: {
                    if count > 1 { // Asegurarse de que el conteo no vaya más allá de 1
                        count -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255)) // Color del signo menos
                        .frame(width: 30, height: 30)
                        .background(Color.white) // Fondo blanco
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2) // Borde del botón
                        )
                }

                // Mostrar el valor actual, asegurándonos que no sea menor a 1
                Text("\(max(count, 1))")
                    .font(.custom("Montserrat-SemiBold", size: 18))
                    .frame(width: 40)

                Button(action: {
                    count += 1
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255)) // Color del signo más
                        .frame(width: 30, height: 30)
                        .background(Color.white) // Fondo blanco
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color(red: 12/255, green: 53/255, blue: 106/255), lineWidth: 2) // Borde del botón
                        )
                }
            }
            .padding(.leading, 10) // Espacio entre el texto y los botones
        }
        .padding(.vertical, 5) // Ajuste del espaciado vertical
        .onAppear {
            // Asegurarse de que el valor inicial sea al menos 1
            if count < 1 {
                count = 1
            }
        }
    }
}

// Preview del componente para probar su funcionamiento con diferentes valores iniciales
struct IncrementDecrementView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IncrementDecrementView(title: "Rooms available for sublet", count: .constant(1))
            IncrementDecrementView(title: "Beds", count: .constant(1))
            IncrementDecrementView(title: "Bathrooms", count: .constant(1))
        }
    }
}
