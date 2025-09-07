import SwiftUI

struct LocationPickerView: View {
    @Binding var selectedLocation: MapLocation
    let locations: [MapLocation]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locations, id: \.name) { location in
                    LocationRow(
                        location: location,
                        isSelected: location.name == selectedLocation.name
                    ) {
                        selectedLocation = location
                        dismiss()
                    }
                }
            }
            .navigationTitle("选择位置")
            .navigationBarItems(
                leading: Button("取消") {
                    dismiss()
                }
            )
        }
    }
}

struct LocationRow: View {
    let location: MapLocation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(location.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LocationPickerView(
        selectedLocation: .constant(MapLocation.beijing),
        locations: [
            MapLocation.beijing,
            MapLocation.shanghai,
            MapLocation.guangzhou,
            MapLocation.shenzhen
        ]
    )
}