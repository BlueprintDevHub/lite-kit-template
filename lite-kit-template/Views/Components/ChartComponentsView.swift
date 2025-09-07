import SwiftUI

struct ChartComponentsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("柱状图")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    SimpleBarChartView()
                        .frame(height: 200)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("折线图")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    SimpleLineChartView()
                        .frame(height: 200)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("饼图")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    SimplePieChartView()
                        .frame(height: 200)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("图表组件")
    }
}

struct SimpleBarChartView: View {
    let data = [
        ChartData(name: "周一", value: 23),
        ChartData(name: "周二", value: 45),
        ChartData(name: "周三", value: 67),
        ChartData(name: "周四", value: 32),
        ChartData(name: "周五", value: 89),
        ChartData(name: "周六", value: 56),
        ChartData(name: "周日", value: 78)
    ]
    
    var body: some View {
        VStack {
            Text("每日数据")
                .font(.headline)
                .padding(.bottom)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data, id: \.name) { item in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.gradient)
                            .frame(width: 30, height: CGFloat(item.value) * 2)
                        
                        Text(item.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct SimpleLineChartView: View {
    let data = [45, 67, 32, 89, 56, 78, 92, 34, 67]
    
    var body: some View {
        VStack {
            Text("趋势图")
                .font(.headline)
                .padding(.bottom)
            
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(data.count - 1)
                    let maxValue = data.max() ?? 100
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(value) / CGFloat(maxValue)) * height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 2)
                
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    let stepX = geometry.size.width / CGFloat(data.count - 1)
                    let maxValue = data.max() ?? 100
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height - (CGFloat(value) / CGFloat(maxValue)) * geometry.size.height
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
            .frame(height: 120)
        }
    }
}

struct SimplePieChartView: View {
    let data = [
        PieChartData(name: "iOS", value: 45, color: .blue),
        PieChartData(name: "Android", value: 30, color: .green),
        PieChartData(name: "Web", value: 20, color: .orange),
        PieChartData(name: "其他", value: 5, color: .gray)
    ]
    
    var body: some View {
        VStack {
            Text("平台分布")
                .font(.headline)
                .padding(.bottom)
            
            HStack(spacing: 30) {
                ZStack {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        let startAngle = data.prefix(index).reduce(0) { $0 + $1.value } * 360 / 100
                        let endAngle = startAngle + item.value * 360 / 100
                        
                        Path { path in
                            path.move(to: CGPoint(x: 60, y: 60))
                            path.addArc(
                                center: CGPoint(x: 60, y: 60),
                                radius: 50,
                                startAngle: .degrees(startAngle - 90),
                                endAngle: .degrees(endAngle - 90),
                                clockwise: false
                            )
                            path.closeSubpath()
                        }
                        .fill(item.color)
                    }
                }
                .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(data, id: \.name) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 12, height: 12)
                            Text("\(item.name): \(item.value)%")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

struct ChartData {
    let name: String
    let value: Int
}

struct PieChartData {
    let name: String
    let value: Double
    let color: Color
}

#Preview {
    NavigationView {
        ChartComponentsView()
    }
}