import SwiftUI

struct TextComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("基础文本") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题文本")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("副标题文本")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("正文文本 - 这是一段正文内容，展示了基础的文本样式。")
                            .font(.body)
                        
                        Text("小号文本")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                ComponentSection("文本样式") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("粗体文本")
                            .fontWeight(.bold)
                        
                        Text("斜体文本")
                            .italic()
                        
                        Text("下划线文本")
                            .underline()
                        
                        Text("删除线文本")
                            .strikethrough()
                        
                        Text("彩色文本")
                            .foregroundColor(.blue)
                        
                        Text("背景色文本")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(4)
                    }
                }
                
                ComponentSection("多行文本") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("这是一段很长的文本，用来演示多行文本的显示效果。当文本内容超过一行时，会自动换行显示。这样可以确保所有内容都能被用户看到。")
                            .lineLimit(nil)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Text("限制两行的文本：这是一段很长的文本内容，但是被限制只能显示两行，超出的内容会用省略号表示...")
                            .lineLimit(2)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                ComponentSection("富文本") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello, ") +
                        Text("World").foregroundColor(.blue).bold() +
                        Text("!")
                        
                        Text("支持**粗体**、*斜体*和`代码`的Markdown文本")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("文本组件")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ComponentSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationView {
        TextComponentsView()
    }
}