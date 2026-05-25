import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    var tint: Color = .appPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(tint)
                Spacer()
                Text("\(value)")
                    .font(.title)
                    .bold()
            }
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
