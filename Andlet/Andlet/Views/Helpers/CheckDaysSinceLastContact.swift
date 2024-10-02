//
//  CheckDaysSinceLastContact.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 1/10/24.
//

import FirebaseFirestore
import FirebaseAuth
import UserNotifications

func checkDaysSinceLastContact() {
    let db = Firestore.firestore()
    
    guard let userEmail = Auth.auth().currentUser?.email else {
        print("Error: No hay usuario logueado")
        return
    }
    
    // Referencia a la colección "user_actions"
    let userActionsRef = db.collection("user_actions")
    
    // Query para buscar documentos con la acción de contacto y el user_id correspondiente
    userActionsRef
        .whereField("action", isEqualTo: "contact")  // Filtramos por acción de contacto
        .whereField("user_id", isEqualTo: userEmail)  // Filtramos por el usuario logueado
        .order(by: "date", descending: true)  // Ordenamos por la fecha de contacto más reciente
        .limit(to: 1)  // Solo obtenemos el contacto más reciente
        .getDocuments { (snapshot, error) in
            if let error = error {
                print("Error al obtener acciones de usuario: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No se encontraron acciones de contacto para el usuario.")
                return
            }
            
            // Obtenemos el documento más reciente (solo debería haber uno debido al limit)
            if let document = documents.first {
                if let data = document.data() as? [String: Any],
                   let lastContactDate = data["date"] as? Timestamp {
                    
                    // Convertimos la fecha a tipo Date
                    let lastContact = lastContactDate.dateValue()
                    let currentDate = Date()
                    
                    // Calculamos la diferencia en días
                    let daysSinceLastContact = Calendar.current.dateComponents([.day], from: lastContact, to: currentDate).day ?? 0
                    
                    print("Días desde el último contacto: \(daysSinceLastContact)")
                    
                    // Si han pasado más de 14 días, enviamos una notificación
                    if daysSinceLastContact > 14 {
                        sendNotification()
                    }
                }
            }
        }
}



func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        if granted {
            print("Permiso concedido para notificaciones.")
        } else if let error = error {
            print("Error al solicitar permiso de notificaciones: \(error)")
        }
    }
}



func sendNotification() {
    let content = UNMutableNotificationContent()
    content.title = "It's been a while!"
    content.body = "It seems like you haven't searched for rentals recently. Your ideal home is waiting for you on Andlet!"
    content.sound = UNNotificationSound.default

    // Configuramos la notificación para que se envíe inmediatamente
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    // Añadimos la notificación al centro de notificaciones
    UNUserNotificationCenter.current().add(request) { (error) in
        if let error = error {
            print("Error al programar la notificación: \(error)")
        } else {
            print("Notificación enviada correctamente.")
        }
    }
}

