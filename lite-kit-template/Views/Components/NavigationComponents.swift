import SwiftUI

struct TabComponentsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("基础TabView") {
                    TabView(selection: $selectedTab) {
                        Text("第一个标签页内容")
                            .tabItem {
                                Image(systemName: "1.circle")
                                Text("标签1")
                            }
                            .tag(0)
                        
                        Text("第二个标签页内容")
                            .tabItem {
                                Image(systemName: "2.circle")
                                Text("标签2")
                            }
                            .tag(1)
                        
                        Text("第三个标签页内容")
                            .tabItem {
                                Image(systemName: "3.circle")
                                Text("标签3")
                            }
                            .tag(2)
                    }
                    .frame(height: 200)
                }
                
                Text("当前选择的标签: \(selectedTab + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("标签页")
    }
}

struct AlertComponentsView: View {
    @State private var showAlert = false
    @State private var showActionSheet = false
    @State private var showSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("弹窗") {
                    VStack(spacing: 12) {
                        Button("显示警告弹窗") {
                            showAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("显示操作表") {
                            showActionSheet = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("显示底部弹窗") {
                            showSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("弹窗与提示")
        .alert("提示", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
            Button("取消", role: .destructive) {}
        } message: {
            Text("这是一个警告弹窗")
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("选择操作"),
                message: Text("请选择一个操作"),
                buttons: [
                    .default(Text("选项1")),
                    .default(Text("选项2")),
                    .destructive(Text("删除")),
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showSheet) {
            NavigationView {
                VStack {
                    Text("这是一个底部弹窗")
                        .font(.title2)
                        .padding()
                    
                    Spacer()
                    
                    Button("关闭") {
                        showSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .navigationTitle("弹窗")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("完成") {
                    showSheet = false
                })
            }
        }
    }
}

struct ToolbarComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("工具栏示例") {
                    Text("工具栏通常显示在导航栏中")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("工具栏")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("编辑") {
                    print("编辑按钮被点击")
                }
            }
        }
    }
}

