import SwiftUI

// Componente Incrementador/Decrementador
struct IncrementDecrementView: View {
    var title: String
    @Binding var count: Int
    
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
                    if count > 0 {
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
                
                Text("\(count)")
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
    }
}

struct IncrementDecrementView_Previews: PreviewProvider {
    static var previews: some View {
        IncrementDecrementView(title: "Sample", count: .constant(0))
    }
}
