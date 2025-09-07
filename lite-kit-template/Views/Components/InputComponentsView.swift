import SwiftUI

struct InputComponentsView: View {
    @State private var textInput = "Alterem"
    @State private var passwordInput = ""
    @State private var multilineText = ""
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("基础输入框") {
                    VStack(spacing: 12) {
                        TextField("请输入文本", text: $textInput)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("请输入密码", text: $passwordInput)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("搜索", text: $searchText)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                ComponentSection("多行文本输入") {
                    VStack(spacing: 12) {
                        Text("TextEditor:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $multilineText)
                            .frame(height: 100)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        if multilineText.isEmpty {
                            Text("在这里输入多行文本...")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                ComponentSection("输入状态显示") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("当前输入: \(textInput.isEmpty ? "无" : textInput)")
                        Text("密码长度: \(passwordInput.count)")
                        Text("搜索内容: \(searchText.isEmpty ? "无" : searchText)")
                        Text("多行文本字数: \(multilineText.count)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                ComponentSection("自定义样式输入框") {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("标题输入框")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("输入标题", text: .constant(""))
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("用户名")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("请输入用户名", text: .constant(""))
                                    .font(.body)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("输入组件")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        InputComponentsView()
    }
}
