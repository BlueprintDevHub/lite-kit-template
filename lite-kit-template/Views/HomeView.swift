import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var hitokotoService = HitokotoService()
    @State private var selectedType: HitokotoType? = nil
    @State private var showCopiedAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Picker("分类", selection: $selectedType) {
                    Text("全部").tag(nil as HitokotoType?)
                    ForEach(HitokotoType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type as HitokotoType?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if hitokotoService.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("获取中...")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let hitokoto = hitokotoService.currentHitokoto {
                            HitokotoCard(hitokoto: hitokoto) {
                                copyToClipboard(hitokoto.hitokoto)
                            }
                        } else if let error = hitokotoService.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                Text(error)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Button("重试") {
                                    Task { await hitokotoService.fetchHitokotoAsync(type: selectedType, forceRefresh: true) }
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("点击下方按钮获取一言")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    // 下拉刷新：强制刷新，跳过缓存
                    await hitokotoService.fetchHitokotoAsync(type: selectedType, forceRefresh: true)
                }
                
                VStack(spacing: 8) {
                    Button(action: {
                        // 点击按钮：强制刷新，确保获取新内容
                        Task { await hitokotoService.fetchHitokotoAsync(type: selectedType, forceRefresh: true) }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("获取一言")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(hitokotoService.isLoading)
                    
                    if let updated = hitokotoService.lastUpdatedAt {
                        Text("上次更新：\(updated.formatted(date: .abbreviated, time: .standard))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("一言")
            .onAppear {
                // 首次进入：缓存优先加载一次（避免 loading 闪烁）
                if hitokotoService.currentHitokoto == nil {
                    Task { await hitokotoService.fetchHitokotoAsync(type: selectedType) }
                }
            }
            .onChange(of: selectedType) { _, _ in
                // 切换分类：缓存优先加载
                Task { await hitokotoService.fetchHitokotoAsync(type: selectedType) }
            }
            .alert("已复制", isPresented: $showCopiedAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text("内容已复制到剪贴板")
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        showCopiedAlert = true
    }
}

struct HitokotoCard: View {
    let hitokoto: Hitokoto
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(hitokoto.hitokoto)
                .font(.title2)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("—— \(hitokoto.from)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    if let fromWho = hitokoto.from_who, !fromWho.isEmpty {
                        Text(fromWho)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(typeDisplayName(for: hitokoto.type))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                            .accessibilityLabel("复制")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func typeDisplayName(for type: String) -> String {
        HitokotoType(rawValue: type)?.displayName ?? "其他"
    }
}

#Preview {
    HomeView()
}
