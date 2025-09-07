import Foundation

struct Hitokoto: Codable, Identifiable {
    let id: Int
    let uuid: String
    let hitokoto: String
    let type: String
    let from: String
    let from_who: String?
    let creator: String
    let creator_uid: Int
    let reviewer: Int
    let commit_from: String
    let created_at: String
    let length: Int
}

enum HitokotoType: String, CaseIterable {
    case anime = "a"
    case comic = "b"
    case game = "c"
    case literature = "d"
    case original = "e"
    case internet = "f"
    case other = "g"
    case movie = "h"
    case poetry = "i"
    case netease = "j"
    case philosophy = "k"
    case funny = "l"
    
    var displayName: String {
        switch self {
        case .anime: return "动画"
        case .comic: return "漫画"
        case .game: return "游戏"
        case .literature: return "文学"
        case .original: return "原创"
        case .internet: return "来自网络"
        case .other: return "其他"
        case .movie: return "影视"
        case .poetry: return "诗词"
        case .netease: return "网易云"
        case .philosophy: return "哲学"
        case .funny: return "抖机灵"
        }
    }
}