import SwiftUI

struct PickerComponentsView: View {
    @State private var selectedValue = 0
    @State private var selectedFruit = "苹果"
    @State private var selectedDate = Date()
    
    let fruits = ["苹果", "香蕉", "橙子", "葡萄"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("分段选择器") {
                    VStack(spacing: 12) {
                        Picker("选择", selection: $selectedValue) {
                            Text("选项1").tag(0)
                            Text("选项2").tag(1)
                            Text("选项3").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("当前选择: 选项\(selectedValue + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ComponentSection("菜单选择器") {
                    VStack(spacing: 12) {
                        Picker("水果", selection: $selectedFruit) {
                            ForEach(fruits, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Text("选择的水果: \(selectedFruit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ComponentSection("日期选择器") {
                    VStack(spacing: 12) {
                        DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                        
                        DatePicker("选择时间", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        
                        Text("选择的日期时间: \(selectedDate.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("选择器")
    }
}

struct SliderStepperView: View {
    @State private var sliderValue: Double = 50
    @State private var stepperValue = 5
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("滑块") {
                    VStack(spacing: 12) {
                        Slider(value: $sliderValue, in: 0...100)
                        
                        Text("当前值: \(Int(sliderValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $sliderValue, in: 0...100) {
                            Text("音量")
                        } minimumValueLabel: {
                            Image(systemName: "speaker.fill")
                        } maximumValueLabel: {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .accentColor(.blue)
                    }
                }
                
                ComponentSection("步进器") {
                    VStack(spacing: 12) {
                        Stepper("数量: \(stepperValue)", value: $stepperValue, in: 0...10)
                        
                        HStack {
                            Text("自定义步进器:")
                            Spacer()
                            Button("-") {
                                if stepperValue > 0 { stepperValue -= 1 }
                            }
                            .frame(width: 30, height: 30)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                            
                            Text("\(stepperValue)")
                                .frame(width: 40)
                            
                            Button("+") {
                                if stepperValue < 10 { stepperValue += 1 }
                            }
                            .frame(width: 30, height: 30)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("滑块与步进器")
    }
}

struct ToggleComponentsView: View {
    @State private var isOn = false
    @State private var wifiEnabled = true
    @State private var bluetoothEnabled = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("开关") {
                    VStack(spacing: 12) {
                        Toggle("基础开关", isOn: $isOn)
                        
                        Toggle("WiFi", isOn: $wifiEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Toggle("蓝牙", isOn: $bluetoothEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        HStack {
                            Image(systemName: "airplane")
                            Toggle("飞行模式", isOn: .constant(false))
                        }
                    }
                }
                
                ComponentSection("状态显示") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("基础开关: \(isOn ? "开启" : "关闭")")
                        Text("WiFi: \(wifiEnabled ? "已连接" : "已断开")")
                        Text("蓝牙: \(bluetoothEnabled ? "已开启" : "已关闭")")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("开关与切换")
    }
}

struct ProgressComponentsView: View {
    @State private var progress: Double = 0.6
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ComponentSection("进度条") {
                    VStack(spacing: 12) {
                        ProgressView(value: progress)
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        HStack {
                            Text("进度:")
                            ProgressView(value: progress)
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                        }
                    }
                }
                
                ComponentSection("加载指示器") {
                    VStack(spacing: 12) {
                        ProgressView()
                        
                        ProgressView("加载中...")
                        
                        if isLoading {
                            ProgressView("正在处理...")
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        Button(isLoading ? "停止" : "开始加载") {
                            isLoading.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                ComponentSection("自定义进度") {
                    VStack(spacing: 12) {
                        HStack {
                            Button("减少") {
                                if progress > 0 { progress -= 0.1 }
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("增加") {
                                if progress < 1 { progress += 0.1 }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(height: 8)
                            .foregroundColor(.gray.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: CGFloat(progress) * 200, height: 8)
                                    .foregroundColor(.green)
                                    .animation(.easeInOut, value: progress),
                                alignment: .leading
                            )
                            .frame(width: 200)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("进度指示器")
    }
}

#Preview {
    NavigationView {
        PickerComponentsView()
    }
}