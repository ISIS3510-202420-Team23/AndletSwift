import Foundation
import FirebaseFirestore  // Asegúrate de importar FirebaseFirestoreSwift para usar @DocumentID

// Enum to restrict the type_user field to "landlord" or "student"
enum ActionType: String, Codable {
    case contact = "contact"
    case filter = "filter"
    case publish = "publish"
}

enum AppType: String, Codable {
    case swift = "swift"
    case flutter = "flutter"
}

// Hacemos que el modelo conforme a Identifiable y Codable
struct UserActionsModel: Identifiable, Codable {
    @DocumentID var id: String?  // ID puede ser opcional, Firestore lo maneja automáticamente
    let action: ActionType
    let app: AppType
    let date: Date
    let user_id: String

    // Inicializador que permite crear un modelo manualmente si es necesario
    init(id: String? = nil, action: ActionType, app: AppType, date: Date, user_id: String) {
        self.id = id
        self.action = action
        self.app = app
        self.date = date
        self.user_id = user_id
    }
}
