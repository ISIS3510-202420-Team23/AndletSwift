//
//  NotificationModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 19/11/24.
//

import Foundation

struct NotificationModel: Identifiable, Hashable {
    let id: String
    let propertyTitle: String
    let savesCount: Int
    let imageKey: String // Ruta o nombre de la imagen
}
