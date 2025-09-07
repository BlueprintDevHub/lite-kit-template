import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "zh-Hans"
    
    enum SupportedLanguage: String, CaseIterable {
        case chinese = "zh-Hans"
        case english = "en"
        case japanese = "ja"
        case korean = "ko"
        
        var displayName: String {
            switch self {
            case .chinese: return "中文"
            case .english: return "English"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            }
        }
    }
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language.rawValue
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(_ language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}