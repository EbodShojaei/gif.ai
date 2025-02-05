import SwiftUI
import SwiftData

@Model
class GifItem {
    var id: String
    var prompt: String
    var base64Data: String
    var createdAt: Date
    var isFavorite: Bool
    
    init(id: String = UUID().uuidString,
         prompt: String,
         base64Data: String,
         createdAt: Date = Date(),
         isFavorite: Bool = false) {
        self.id = id
        self.prompt = prompt
        self.base64Data = base64Data
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}
