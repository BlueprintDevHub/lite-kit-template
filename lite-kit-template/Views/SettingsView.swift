import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLanguage = "中文"
    @State private var enableNotifications = true
    @State private var autoSync = true
    @State private var scrollOffset: CGFloat = 0
    
    let languages = ["中文", "English", "日本語", "한국어"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    appearanceSection
                    languageSection
                    notificationSection
                    dataSection
                    advancedSection
                    aboutSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 50)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
    
    private var settingsHeader: some View {
        VStack {
            HStack(spacing: 16) {
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("设置")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 60)
            
            Spacer()
        }
    }
    
    private var appearanceSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("外观")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRowView(
                    icon: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill",
                    title: "深色模式",
                    iconColor: themeManager.isDarkMode ? .purple : .orange,
                    themeManager: themeManager,
                    trailing: {
                        Toggle("", isOn: $themeManager.isDarkMode)
                            .labelsHidden()
                    }
                )
                
                SettingRowView(
                    icon: "textformat",
                    title: "字体大小",
                    iconColor: .blue,
                    themeManager: themeManager,
                    trailing: {
                        Picker("字体大小", selection: $themeManager.fontManager.fontScale) {
                            ForEach(FontManager.FontSize.allCases, id: \.self) { size in
                                Text(size.rawValue).tag(size.scale)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                )
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var languageSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("语言与地区")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRowView(
                    icon: "globe",
                    title: "语言",
                    iconColor: .green,
                    themeManager: themeManager,
                    trailing: {
                        Picker("语言", selection: $selectedLanguage) {
                            ForEach(languages, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                )
                
                SettingRowView(
                    icon: "location",
                    title: "地区",
                    subtitle: "中国",
                    iconColor: .red,
                    showChevron: true,
                    themeManager: themeManager
                ) {}
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var notificationSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("通知")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRowView(
                    icon: "bell.fill",
                    title: "推送通知",
                    iconColor: .orange,
                    themeManager: themeManager,
                    trailing: {
                        Toggle("", isOn: $enableNotifications)
                            .labelsHidden()
                    }
                )
                
                if enableNotifications {
                    SettingRowView(
                        icon: "speaker.wave.2",
                        title: "通知声音",
                        subtitle: "默认",
                        iconColor: .blue,
                        showChevron: true,
                        themeManager: themeManager
                    ) {}
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var dataSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("数据与存储")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRowView(
                    icon: "icloud.fill",
                    title: "自动同步",
                    iconColor: .blue,
                    themeManager: themeManager,
                    trailing: {
                        Toggle("", isOn: $autoSync)
                            .labelsHidden()
                    }
                )
                
                SettingRowView(
                    icon: "trash",
                    title: "清除缓存",
                    subtitle: "128 MB",
                    iconColor: .red,
                    showChevron: true,
                    themeManager: themeManager
                ) {}
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var advancedSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("高级设置")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SettingRowView(
                    icon: "wrench.and.screwdriver",
                    title: "开发者选项",
                    iconColor: .gray,
                    showChevron: true,
                    themeManager: themeManager
                ) {}
                
                SettingRowView(
                    icon: "arrow.clockwise",
                    title: "重置所有设置",
                    iconColor: .blue,
                    themeManager: themeManager
                ) {
                    resetAllSettings()
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("关于")
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("lite-kit-template")
                        .dynamicFont(.title2, fontManager: themeManager.fontManager)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0 (Build 1)")
                        .dynamicFont(.caption, fontManager: themeManager.fontManager)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func resetAllSettings() {
        themeManager.isDarkMode = false
        selectedLanguage = "中文"
        enableNotifications = true
        autoSync = true
    }
}

// 滚动偏移量监听
struct SettingsScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 设置行组件
struct SettingRowView<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let showChevron: Bool
    let themeManager: ThemeManager?
    let trailing: () -> Trailing
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = .blue,
        showChevron: Bool = false,
        themeManager: ThemeManager? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        action: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.showChevron = showChevron
        self.themeManager = themeManager
        self.trailing = trailing
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    if let themeManager = themeManager {
                        Text(title)
                            .foregroundColor(.primary)
                            .dynamicFont(.body, fontManager: themeManager.fontManager)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .foregroundColor(.secondary)
                                .dynamicFont(.caption, fontManager: themeManager.fontManager)
                        }
                    } else {
                        Text(title)
                            .foregroundColor(.primary)
                            .font(.body)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                trailing()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(themeManager: ThemeManager())
}