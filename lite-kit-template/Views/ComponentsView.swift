import SwiftUI

struct ComponentsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("基础组件") {
                    NavigationLink("文本组件", destination: TextComponentsView())
                    NavigationLink("按钮组件", destination: ButtonComponentsView())
                    NavigationLink("输入组件", destination: InputComponentsView())
                    NavigationLink("图片组件", destination: ImageComponentsView())
                }
                
                Section("布局组件") {
                    NavigationLink("堆栈布局", destination: StackLayoutView())
                    NavigationLink("网格布局", destination: GridLayoutView())
                    NavigationLink("滚动视图", destination: ScrollComponentsView())
                }
                
                Section("交互组件") {
                    NavigationLink("选择器", destination: PickerComponentsView())
                    NavigationLink("滑块与步进器", destination: SliderStepperView())
                    NavigationLink("开关与切换", destination: ToggleComponentsView())
                    NavigationLink("进度指示器", destination: ProgressComponentsView())
                }
                
                Section("导航组件") {
                    NavigationLink("标签页", destination: TabComponentsView())
                    NavigationLink("弹窗与提示", destination: AlertComponentsView())
                    NavigationLink("工具栏", destination: ToolbarComponentsView())
                }
                
                Section("高级组件") {
                    NavigationLink("图表组件", destination: ChartComponentsView())
                    NavigationLink("地图组件", destination: RealMapComponentsView())
                    NavigationLink("动画效果", destination: AnimationComponentsView())
                }
            }
            .navigationTitle("Swift组件")
        }
    }
}

#Preview {
    ComponentsView()
}