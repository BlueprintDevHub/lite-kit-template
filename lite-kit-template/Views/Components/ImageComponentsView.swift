import SwiftUI

struct ImageComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("SF Symbols图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(["house", "heart.fill", "star", "person.circle", "bell", "gear", "camera", "photo", "map", "cloud", "sun.max", "moon"], id: \.self) { iconName in
                            VStack {
                                Image(systemName: iconName)
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text(iconName)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                
                ComponentSection("图片样式") {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                Text("默认")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                                Text("圆形")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                    .frame(width: 80, height: 80)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(12)
                                Text("圆角")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                ComponentSection("图片效果") {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                                    .shadow(radius: 5)
                                Text("阴影效果")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                                    .scaleEffect(1.2)
                                Text("缩放效果")
                                    .font(.caption)
                            }
                            
                            VStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                    .rotationEffect(.degrees(45))
                                Text("旋转效果")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                ComponentSection("头像示例") {
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            Text("小头像")
                                .font(.caption)
                        }
                        
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(radius: 3)
                            Text("中头像")
                                .font(.caption)
                        }
                        
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.purple)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 4
                                        )
                                )
                            Text("大头像")
                                .font(.caption)
                        }
                    }
                }
                
                ComponentSection("占位符图片") {
                    VStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 120)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                    Text("图片占位符")
                                        .foregroundColor(.gray)
                                }
                            )
                            .cornerRadius(8)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 80)
                            .overlay(
                                Text("渐变背景")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("图片组件")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        ImageComponentsView()
    }
}