import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var profileImage: UIImage? = nil
    @State private var showingSettings = false
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 200
    
    var body: some View {
        ZStack(alignment: .top) {
            // 状态栏背景渐变
            statusBarBackground
            
            // 主滚动视图
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // 原始头部
                        profileHeader
                            .id("header")
                            .opacity(headerOpacity)
                            .offset(y: headerOffset)
                            .background(scrollOffsetReader)
                        
                        // 列表内容
                        contentSections
                    }
                }
            }
            
            // Telegram-style Dynamic Island 吸附效果
            if shouldShowStickyHeader {
                stickyHeader
                    .zIndex(1)
                    .transition(stickyHeaderTransition)
                    .animation(.spring(
                        response: AnimationConstants.springResponse,
                        dampingFraction: AnimationConstants.springDamping
                    ), value: shouldShowStickyHeader)
            }
        }
        .navigationBarHidden(true)
        .statusBarStyle(scrollOffset > 30 ? .default : .lightContent)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .environmentObject(themeManager)
        .sheet(isPresented: $showingSettings) {
            SettingsView(themeManager: themeManager)
        }
    }
    
    // MARK: - Animation Constants
    
    private struct AnimationConstants {
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
        static let easeInOutDuration: Double = 0.4
        static let stickyHeaderScale: CGFloat = 0.9
        static let stickyHeaderExitScale: CGFloat = 1.1
    }
    
    // MARK: - Computed Properties
    
    private var shouldShowStickyHeader: Bool {
        scrollOffset > 80
    }
    
    private var headerOpacity: Double {
        let threshold: CGFloat = 50
        return scrollOffset < threshold ? 1.0 : max(0.0, 1.0 - ((scrollOffset - threshold) / threshold))
    }
    
    private var headerOffset: CGFloat {
        let threshold: CGFloat = 50
        return scrollOffset < threshold ? 0 : min(0.0, (scrollOffset - threshold) * (-0.3))
    }
    
    private var statusBarBackgroundOpacity: Double {
        scrollOffset > 80 ? 0.005 : 0.08
    }
    
    private var statusBarBackgroundOpacitySecondary: Double {
        scrollOffset > 80 ? 0.002 : 0.04
    }
    
    // MARK: - View Components
    
    private var statusBarBackground: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(statusBarBackgroundOpacity),
                        Color.purple.opacity(statusBarBackgroundOpacitySecondary)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: getSafeAreaTop())
            .animation(.easeInOut(duration: AnimationConstants.easeInOutDuration), value: scrollOffset)
            .edgesIgnoringSafeArea(.top)
    }
    
    private var scrollOffsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .onChange(of: proxy.frame(in: .global).minY) { _, newValue in
                    let initialY = getSafeAreaTop() + 50
                    scrollOffset = max(0, initialY - newValue)
                }
        }
    }
    
    private var contentSections: some View {
        LazyVStack(spacing: 16) {
            personalSection
            settingsSection
            aboutSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 50)
        .padding(.top, 20)
    }
    
    private var stickyHeaderTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: AnimationConstants.stickyHeaderScale)).combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .scale(scale: AnimationConstants.stickyHeaderExitScale)).combined(with: .move(edge: .top))
        )
    }
    
    private var stickyHeader: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 6)
            
            // 真正的灵动岛吸附效果
            HStack(spacing: 12) {
                AvatarUploadView(
                    profileImage: $profileImage,
                    size: 32,
                    showEditButton: false
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alterem")
                        .dynamicFont(.subheadline, fontManager: themeManager.fontManager)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("iOS开发者")
                        .dynamicFont(.caption, fontManager: themeManager.fontManager)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
                    .frame(height: 40)
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 获取安全区域顶部高度
    private func getSafeAreaTop() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 44 // 默认值
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            AvatarUploadView(
                profileImage: $profileImage,
                size: 120,
                showEditButton: true
            )
            
            VStack(spacing: 4) {
                Text("Alterem")
                    .dynamicFont(.title2, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                
                Text("iOS开发者，热爱编程与设计")
                    .dynamicFont(.subheadline, fontManager: themeManager.fontManager)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .frame(height: headerHeight)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var personalSection: some View {
        SectionCard(
            title: "个人信息",
            themeManager: themeManager
        ) {
            VStack(spacing: 8) {
                SettingRow(
                    icon: "person.circle",
                    title: "编辑资料",
                    subtitle: "修改个人信息",
                    iconColor: .blue,
                    themeManager: themeManager
                ) {
                    print("编辑资料")
                }
                
                SettingRow(
                    icon: "heart.circle",
                    title: "我的收藏",
                    subtitle: "查看收藏的内容",
                    iconColor: .red,
                    themeManager: themeManager
                ) {
                    print("我的收藏")
                }
                
                SettingRow(
                    icon: "clock.circle",
                    title: "浏览历史",
                    subtitle: "查看最近浏览",
                    iconColor: .orange,
                    themeManager: themeManager
                ) {
                    print("浏览历史")
                }
            }
        }
    }
    
    private var settingsSection: some View {
        SectionCard(
            title: "设置",
            themeManager: themeManager
        ) {
            VStack(spacing: 8) {
                SettingRow(
                    icon: "gearshape.circle",
                    title: "通用设置",
                    subtitle: "主题、语言等设置",
                    iconColor: .gray,
                    themeManager: themeManager
                ) {
                    showingSettings = true
                }
                
                SettingRow(
                    icon: "bell.circle",
                    title: "通知设置",
                    subtitle: "管理推送通知",
                    iconColor: .green,
                    themeManager: themeManager
                ) {
                    print("通知设置")
                }
                
                SettingRow(
                    icon: "lock.circle",
                    title: "隐私设置",
                    subtitle: "账户安全与隐私",
                    iconColor: .purple,
                    themeManager: themeManager
                ) {
                    print("隐私设置")
                }
                
                SettingRow(
                    icon: "icloud.circle",
                    title: "数据同步",
                    subtitle: "云端数据备份",
                    iconColor: .blue,
                    themeManager: themeManager
                ) {
                    print("数据同步")
                }
            }
        }
    }
    
    private var aboutSection: some View {
        SectionCard(
            title: "关于",
            themeManager: themeManager
        ) {
            VStack(spacing: 8) {
                SettingRow(
                    icon: "questionmark.circle",
                    title: "帮助与反馈",
                    subtitle: "获取帮助或提交反馈",
                    iconColor: .cyan,
                    themeManager: themeManager
                ) {
                    print("帮助与反馈")
                }
                
                SettingRow(
                    icon: "doc.circle",
                    title: "使用条款",
                    subtitle: "查看服务条款",
                    iconColor: .indigo,
                    themeManager: themeManager
                ) {
                    print("使用条款")
                }
                
                SettingRow(
                    icon: "info.circle",
                    title: "关于应用",
                    subtitle: "版本 1.0.0",
                    iconColor: .secondary,
                    themeManager: themeManager
                ) {
                    print("关于应用")
                }
            }
        }
    }
}

// MARK: - Helper Extensions

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        background(StatusBarStyleModifier(style: style))
    }
}

struct StatusBarStyleModifier: UIViewControllerRepresentable {
    let style: UIStatusBarStyle
    
    func makeUIViewController(context: Context) -> StatusBarViewController {
        StatusBarViewController(style: style)
    }
    
    func updateUIViewController(_ uiViewController: StatusBarViewController, context: Context) {
        uiViewController.statusBarStyle = style
    }
}

class StatusBarViewController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    init(style: UIStatusBarStyle) {
        self.statusBarStyle = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
}

// MARK: - Reusable Components

struct SectionCard<Content: View>: View {
    let title: String
    let themeManager: ThemeManager
    let content: Content
    
    init(title: String, themeManager: ThemeManager, @ViewBuilder content: () -> Content) {
        self.title = title
        self.themeManager = themeManager
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .dynamicFont(.headline, fontManager: themeManager.fontManager)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            content
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let themeManager: ThemeManager
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                        .dynamicFont(.body, fontManager: themeManager.fontManager)
                    
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .dynamicFont(.caption, fontManager: themeManager.fontManager)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .dynamicFont(.caption, fontManager: themeManager.fontManager)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
}
