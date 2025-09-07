import SwiftUI

struct AnimationComponentsView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("基础动画")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 50, height: 50)
                                .scaleEffect(scale)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
                            
                            Rectangle()
                                .fill(.green)
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotationAngle)
                        }
                        
                        Button(isAnimating ? "停止动画" : "开始动画") {
                            isAnimating.toggle()
                            if isAnimating {
                                scale = 1.5
                                rotationAngle = 360
                            } else {
                                scale = 1.0
                                rotationAngle = 0
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("弹簧动画")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        Capsule()
                            .fill(.purple)
                            .frame(width: 100, height: 50)
                            .offset(offset)
                        
                        Button("触发弹簧效果") {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.3, blendDuration: 0)) {
                                offset = offset == .zero ? CGSize(width: 100, height: 0) : .zero
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("加载动画")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LoadingAnimationView()
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("动画效果")
    }
}

struct LoadingAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.orange)
                    .frame(width: 15, height: 15)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    NavigationView {
        AnimationComponentsView()
    }
}