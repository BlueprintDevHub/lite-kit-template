import SwiftUI

class FontManager: ObservableObject {
    @Published var fontScale: Double = 1.0
    
    enum FontSize: String, CaseIterable {
        case small = "小"
        case standard = "标准"
        case large = "大"
        case extraLarge = "超大"
        
        var scale: Double {
            switch self {
            case .small: return 0.8
            case .standard: return 1.0
            case .large: return 1.2
            case .extraLarge: return 1.4
            }
        }
    }
    
    var currentFontSize: FontSize {
        FontSize.allCases.first { $0.scale == fontScale } ?? .standard
    }
    
    func setFontSize(_ size: FontSize) {
        fontScale = size.scale
    }
}