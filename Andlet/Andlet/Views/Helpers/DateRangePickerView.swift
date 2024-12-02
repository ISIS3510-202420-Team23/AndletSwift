import SwiftUI

struct DateRangePickerView: View {
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @Binding var startDate: Date // Fecha inicial
    @Binding var endDate: Date // Fecha final
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    let secondaryColor = Color(red: 255/255, green: 244/255, blue: 207/255)


    // Formateador de fecha
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Formato DD/MM/YYYY
        return formatter
    }()

    var body: some View {
        VStack {
            // Texto superior centrado
            Text("For how long will be available?")
                .font(.custom("Montserrat-Light", size: 18))
                .foregroundColor(primaryColor)
                .padding(.bottom, 10)
            
            // HStack centrada con los botones alargados y el guion
            HStack {
                // Botón para seleccionar fecha inicial
                Button(action: {
                    showStartDatePicker.toggle()
                }) {
                    Text(dateFormatter.string(from: startDate))
                        .frame(width: 140, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(secondaryColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(primaryColor, lineWidth: 2)
                                )
                        )
                        .foregroundColor(primaryColor)
                }
                .sheet(isPresented: $showStartDatePicker) {
                    // Desplegar un DatePicker en una hoja modal
                    VStack {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle()) // Estilo gráfico del DatePicker
                        Button("Done") {
                            showStartDatePicker.toggle() // Cerrar el DatePicker
                        }
                    }
                    .padding()
                }
                
                // Guion entre las fechas
                Text("--")
                    .font(.custom("Montserrat-Light", size: 30))
                    .foregroundColor(primaryColor)
                    .padding(.horizontal, 10)
                
                // Botón para seleccionar fecha final
                Button(action: {
                    showEndDatePicker.toggle() // Mostrar el calendario para fecha final
                }) {
                    Text(dateFormatter.string(from: endDate)) // Mostrar la fecha en el botón
                        .frame(width: 140, height: 40) // Tamaño del botón
                        .foregroundColor(primaryColor) // Color del texto
                        .background(secondaryColor) // Fondo amarillo
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(primaryColor, lineWidth: 2) // Borde azul
                        )
                }
                .sheet(isPresented: $showEndDatePicker) {
                    // Desplegar un DatePicker en una hoja modal
                    VStack {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle()) // Estilo gráfico del DatePicker
                        Button("Done") {
                            showEndDatePicker.toggle() // Cerrar el DatePicker
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
