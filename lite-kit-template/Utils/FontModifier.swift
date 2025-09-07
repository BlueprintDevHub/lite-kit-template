import SwiftUI

struct DynamicFont: ViewModifier {
    let baseFont: Font
    @ObservedObject var fontManager: FontManager
    
    func body(content: Content) -> some View {
        content
            .font(scaledFont(baseFont))
    }
    
    private func scaledFont(_ font: Font) -> Font {
        switch font {
        case .largeTitle:
            return Font.system(size: 34 * fontManager.fontScale, weight: .regular, design: .default)
        case .title:
            return Font.system(size: 28 * fontManager.fontScale, weight: .regular, design: .default)
        case .title2:
            return Font.system(size: 22 * fontManager.fontScale, weight: .regular, design: .default)
        case .title3:
            return Font.system(size: 20 * fontManager.fontScale, weight: .regular, design: .default)
        case .headline:
            return Font.system(size: 17 * fontManager.fontScale, weight: .semibold, design: .default)
        case .body:
            return Font.system(size: 17 * fontManager.fontScale, weight: .regular, design: .default)
        case .callout:
            return Font.system(size: 16 * fontManager.fontScale, weight: .regular, design: .default)
        case .subheadline:
            return Font.system(size: 15 * fontManager.fontScale, weight: .regular, design: .default)
        case .footnote:
            return Font.system(size: 13 * fontManager.fontScale, weight: .regular, design: .default)
        case .caption:
            return Font.system(size: 12 * fontManager.fontScale, weight: .regular, design: .default)
        case .caption2:
            return Font.system(size: 11 * fontManager.fontScale, weight: .regular, design: .default)
        default:
            return Font.system(size: 17 * fontManager.fontScale, weight: .regular, design: .default)
        }
    }
}

extension View {
    func dynamicFont(_ font: Font, fontManager: FontManager) -> some View {
        self.modifier(DynamicFont(baseFont: font, fontManager: fontManager))
    }
}

extension Text {
    func adaptiveFont(_ font: Font, fontManager: FontManager) -> some View {
        self.modifier(DynamicFont(baseFont: font, fontManager: fontManager))
    }
}