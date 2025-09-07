import SwiftUI

struct StackLayoutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("VStack - 垂直堆栈") {
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 40)
                        Rectangle()
                            .fill(Color.green)
                            .frame(height: 40)
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 40)
                    }
                    .frame(height: 140)
                }
                
                ComponentSection("HStack - 水平堆栈") {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 60)
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 60)
                        Rectangle()
                            .fill(Color.pink)
                            .frame(width: 60)
                    }
                    .frame(height: 60)
                }
                
                ComponentSection("ZStack - 层叠堆栈") {
                    ZStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(Color.red.opacity(0.7))
                            .frame(width: 80, height: 80)
                        
                        Text("文本")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .frame(height: 140)
                }
            }
            .padding()
        }
        .navigationTitle("堆栈布局")
    }
}

struct GridLayoutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("LazyVGrid - 垂直网格") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(1...9, id: \.self) { number in
                            Rectangle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(height: 60)
                                .overlay(
                                    Text("\(number)")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("网格布局")
    }
}

struct ScrollComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("垂直滚动") {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(1...10, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(height: 40)
                                    .overlay(Text("项目 \(index)"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(height: 200)
                }
                
                ComponentSection("水平滚动") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1...10, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.green.opacity(0.3))
                                    .frame(width: 100, height: 80)
                                    .overlay(Text("\(index)"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("滚动视图")
    }
}

#Preview {
    NavigationView {
        StackLayoutView()
    }
}