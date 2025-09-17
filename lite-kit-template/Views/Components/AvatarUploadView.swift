import SwiftUI
import PhotosUI
import UIKit

struct AvatarUploadView: View {
    @Binding var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingPhotosPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = false
    
    let size: CGFloat
    let showEditButton: Bool
    
    init(profileImage: Binding<UIImage?>, size: CGFloat = 120, showEditButton: Bool = true) {
        self._profileImage = profileImage
        self.size = size
        self.showEditButton = showEditButton
    }
    
    var body: some View {
        ZStack {
            avatarDisplay
            
            if showEditButton {
                editButton
            }
            
            if isLoading {
                loadingOverlay
            }
        }
        .confirmationDialog("选择头像", isPresented: $showingImagePicker) {
            Button("拍照") {
                showingCamera = true
            }
            
            Button("从相册选择") {
                showingPhotosPicker = true
            }
            
            if profileImage != nil {
                Button("删除头像", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
            
            Button("取消", role: .cancel) {}
        }
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadSelectedImage(from: newItem)
            }
        }
        // 统一使用已有的 ImagePicker（相机）
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $profileImage, sourceType: .camera)
        }
        .alert("删除头像", isPresented: $showingDeleteConfirmation) {
            Button("删除", role: .destructive) {
                withAnimation(.easeInOut) {
                    profileImage = nil
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确定要删除当前头像吗？")
        }
    }
    
    private func loadSelectedImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        profileImage = image
                        isLoading = false
                    }
                }
            } else {
                await MainActor.run { isLoading = false }
            }
        } catch {
            await MainActor.run { isLoading = false }
        }
    }
    
    private var avatarDisplay: some View {
        Group {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .accessibilityLabel("头像")
            } else {
                defaultAvatar
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: profileImage != nil)
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue,
                        Color.purple,
                        Color.pink.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .accessibilityLabel("默认头像")
    }
    
    private var editButton: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            Circle()
                .fill(Color.blue)
                .frame(width: size * 0.3, height: size * 0.3)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .offset(x: size * 0.3, y: size * 0.3)
        .scaleEffect(showingImagePicker ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingImagePicker)
        .accessibilityLabel("编辑头像")
    }
    
    private var loadingOverlay: some View {
        Circle()
            .fill(Color.black.opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            )
            .accessibilityLabel("图片加载中")
    }
}

#Preview {
    struct AvatarPreview: View {
        @State private var image: UIImage? = nil
        
        var body: some View {
            VStack(spacing: 30) {
                AvatarUploadView(profileImage: $image, size: 120)
                
                AvatarUploadView(profileImage: $image, size: 80)
                
                AvatarUploadView(profileImage: $image, size: 50, showEditButton: false)
            }
            .padding()
        }
    }
    
    return AvatarPreview()
}
