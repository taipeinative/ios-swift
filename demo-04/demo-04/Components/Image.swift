import SwiftUI

struct AsyncImageHelper: View {
    let urlString: String
    let height: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
                    .foregroundColor(.secondary)
            @unknown default:
                EmptyView()
            }
        }
    }
}