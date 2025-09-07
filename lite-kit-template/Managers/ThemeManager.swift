import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode = false
    @Published var fontManager = FontManager()
    @Published var localizationManager = LocalizationManager()
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}