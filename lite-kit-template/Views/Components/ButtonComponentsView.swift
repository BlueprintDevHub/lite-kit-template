import SwiftUI

struct ButtonComponentsView: View {
    @State private var isPressed = false
    @State private var counter = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("基础按钮") {
                    VStack(spacing: 12) {
                        Button("默认按钮") {
                            print("默认按钮被点击")
                        }
                        
                        Button("主要按钮") {
                            counter += 1
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("边框按钮") {
                            print("边框按钮被点击")
                        }
                        .buttonStyle(.bordered)
                        
                        Button("文本按钮") {
                            print("文本按钮被点击")
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                ComponentSection("按钮样式") {
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            Text("自定义背景按钮")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {}) {
                            Text("渐变背景按钮")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                        
                        Button(action: {}) {
                            Text("圆形按钮")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                }
                
                ComponentSection("图标按钮") {
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .font(.title2)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus")
                                Text("添加")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                }
                
                ComponentSection("交互状态") {
                    VStack(spacing: 12) {
                        Button(action: {
                            isPressed.toggle()
                        }) {
                            Text(isPressed ? "已按下" : "未按下")
                                .foregroundColor(isPressed ? .white : .blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isPressed ? Color.blue : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        
                        Text("计数器: \(counter)")
                            .font(.title2)
                        
                        Button("禁用按钮") {}
                            .disabled(true)
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("按钮组件")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        ButtonComponentsView()
    }
}