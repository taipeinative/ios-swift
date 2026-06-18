import CoreLocation
import MapKit
import SwiftData
import SwiftUI

struct ReviewDetailView: View {
    let review: Review

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteDialog = false
    @State private var showingEditSheet = false
    @State private var selectedPhotoIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let target = review.target {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(target.name)
                            .font(.title2.bold())

                        Text(target.summaryText)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.shared.secondaryText)

                        NavigationLink {
                            TargetDetailView(target: target)
                        } label: {
                            Text("查看完整目標資訊")
                                .font(.subheadline.bold())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("第 \(review.reviewCount) 次", systemImage: "repeat")
                        Spacer()
                        Label(String(format: "%.1f 分", review.score), systemImage: "star.fill")
                            .foregroundStyle(AppColors.shared.score)
                    }
                    .font(.headline)

                    Text(DateFormatter.reviewDate.string(from: review.watched))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.shared.secondaryText)

                    if !review.comment.isEmpty {
                        Text(review.comment)
                            .font(.body)
                    }

                    if !review.photos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(review.photos.enumerated()), id: \.offset) { index, attachment in
                                    Button {
                                        selectedPhotoIndex = index
                                    } label: {
                                        if let image = UIImage(data: attachment.data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 180, height: 180)
                                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(AppColors.shared.standardStroke)
                }
            }
            .padding(20)
        }
        .navigationTitle("評論詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }

                Button(role: .destructive) {
                    showingDeleteDialog = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                ReviewFormView(mode: .edit(review: review))
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { selectedPhotoIndex != nil },
            set: { if !$0 { selectedPhotoIndex = nil } }
        )) {
            if let selectedPhotoIndex {
                PhotoGalleryViewer(attachments: review.photos, initialIndex: selectedPhotoIndex)
            }
        }
        .alert("確定刪除這則評論嗎？", isPresented: $showingDeleteDialog) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                review.target?.reviews.removeAll { $0.id == review.id }
                modelContext.delete(review)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("刪除後將無法復原。")
        }
    }
}

struct TargetDetailView: View {
    let target: Target

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteDialog = false
    @State private var showingEditSheet = false
    @State private var selectedPhotoIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                TargetDetailPhotoStrip(target: target, selectedPhotoIndex: $selectedPhotoIndex)

                TargetDetailSummary(target: target)

                TargetRelatedInfoSection(attributes: target.relatedInfoGroups)

                if let address = target.addressText {
                    TargetAddressSection(address: address, targetName: target.name)
                }

                TargetLinksSection(links: target.linkAttributes)
            }
            .padding(20)
        }
        .navigationTitle("目標詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }

                Button(role: .destructive) {
                    showingDeleteDialog = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                TargetFormView(mode: .edit(target: target))
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { selectedPhotoIndex != nil },
            set: { if !$0 { selectedPhotoIndex = nil } }
        )) {
            if let selectedPhotoIndex {
                PhotoGalleryViewer(attachments: target.photos, initialIndex: selectedPhotoIndex)
            }
        }
        .alert("確定刪除此目標與其所有評論嗎？", isPresented: $showingDeleteDialog) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                for review in target.reviews {
                    modelContext.delete(review)
                }
                modelContext.delete(target)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("刪除後將無法復原。")
        }
    }
}

private struct TargetDetailPhotoStrip: View {
    let target: Target
    @Binding var selectedPhotoIndex: Int?

    var body: some View {
        Group {
            if target.photos.isEmpty {
                Image(.placeholder)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .padding(24)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            } else {
                if target.photos.count == 1, let attachment = target.photos.first {
                    Button {
                        selectedPhotoIndex = 0
                    } label: {
                        if let image = UIImage(data: attachment.data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(target.photos.enumerated()), id: \.offset) { index, attachment in
                                Button {
                                    selectedPhotoIndex = index
                                } label: {
                                    if let image = UIImage(data: attachment.data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 280, height: 240)
                                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct TargetDetailSummary: View {
    let target: Target

    var body: some View {
        VStack(spacing: 14) {
            Text(target.name)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Label(target.type.title, systemImage: target.type.symbolName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(target.type.color)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(target.type.color.opacity(0.15), in: Capsule())

            if let descriptions = (target.descriptions ?? "").nilIfEmpty {
                Text(descriptions)
                    .font(.body)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TargetRelatedInfoSection: View {
    let attributes: [TargetAttributeGroup]

    var body: some View {
        if !attributes.isEmpty {
            DetailSectionCard(title: "相關資訊") {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(attributes) { group in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(group.title)
                                .font(.subheadline.bold())
                                .padding(.leading, 12)

                            Text(group.value)
                                .font(.body)
                                .foregroundStyle(AppColors.shared.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
}

private struct TargetAddressSection: View {
    let address: String
    let targetName: String

    @State private var coordinate: CLLocationCoordinate2D?
    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        DetailSectionCard(title: "地址") {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Text(address)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CopyButton(text: address)
                }

                if let coordinate {
                    Text(coordinate.displayText)
                        .font(.caption)
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .padding(.bottom, 4)

                    Map(position: $mapPosition) {
                        Marker(targetName, coordinate: coordinate)
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
        }
        .task(id: address) {
            await resolveAddress()
        }
    }

    private func resolveAddress() async {
        coordinate = nil
        mapPosition = .automatic

        guard let request = MKGeocodingRequest(addressString: address),
              let mapItems = try? await request.mapItems,
              let resolvedCoordinate = mapItems.first?.location.coordinate else {
            return
        }

        coordinate = resolvedCoordinate
        mapPosition = .region(
            MKCoordinateRegion(
                center: resolvedCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

private struct TargetLinksSection: View {
    let links: [TargetLinkItem]

    var body: some View {
        if !links.isEmpty {
            DetailSectionCard(title: "相關連結") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(links) { link in
                        if let url = link.url {
                            Link(destination: url) {
                                TargetLinkRow(link: link)
                            }
                            .buttonStyle(.plain)
                        } else {
                            TargetLinkRow(link: link)
                        }
                    }
                }
            }
        }
    }
}

private struct TargetLinkRow: View {
    let link: TargetLinkItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "link")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.shared.link)
                .frame(width: 30, height: 30)
                .background(AppColors.shared.link.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(link.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppColors.shared.primaryText)

                if let rawURL = link.rawURL.nilIfEmpty {
                    Text(rawURL)
                        .font(.caption)
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if link.url != nil {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.shared.secondaryText)
            }
        }
        .padding(12)
        .background(AppColors.shared.subtleFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DetailSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3.bold())

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .background(AppColors.shared.primarySurface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct CopyButton: View {
    let text: String

    @State private var didCopy = false

    var body: some View {
        Button {
            UIPasteboard.general.string = text

            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                didCopy = true
            }

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.25))
                withAnimation(.easeOut(duration: 0.2)) {
                    didCopy = false
                }
            }
        } label: {
            Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(didCopy ? AppColors.shared.success : AppColors.shared.secondaryText)
                .frame(width: 28, height: 28)
                .background(AppColors.shared.subtleFill, in: Circle())
                .contentTransition(.symbolEffect(.replace))
                .accessibilityLabel(didCopy ? "已複製" : "複製")
                .accessibilityValue(text)
        }
        .buttonStyle(.plain)
    }
}

private struct TargetAttributeGroup: Identifiable {
    let type: TargetAttributeType
    let value: String

    var id: TargetAttributeType { type }
    var title: String { type.title }
}

private struct TargetLinkItem: Identifiable {
    let id: UUID
    let title: String
    let rawURL: String

    var url: URL? {
        if let url = URL(string: rawURL), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(rawURL)")
    }
}

@MainActor
private extension Target {
    var relatedInfoGroups: [TargetAttributeGroup] {
        let groupedAttributes = Dictionary(grouping: attributes.filter { attribute in
            attribute.type != .address && attribute.type != .link && !attribute.formattedValue.isEmpty
        }, by: \.type)

        return TargetAttributeType.allCases.compactMap { type in
            guard let values = groupedAttributes[type] else { return nil }
            let mergedValue = values
                .map(\.formattedValue)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0 != "未填寫" }
                .joined(separator: "・")

            guard !mergedValue.isEmpty else { return nil }
            return TargetAttributeGroup(type: type, value: mergedValue)
        }
    }

    var addressText: String? {
        attributes
            .first(where: { $0.type == .address })?
            .displayValue
            .nilIfEmpty
    }

    var linkAttributes: [TargetLinkItem] {
        attributes
            .filter { $0.type == .link }
            .compactMap { attribute in
                guard let rawURL = attribute.secondaryValue?.nilIfEmpty else { return nil }
                return TargetLinkItem(
                    id: attribute.id,
                    title: attribute.displayValue.nilIfEmpty ?? rawURL,
                    rawURL: rawURL
                )
            }
    }
}

private extension TargetType {
    var symbolName: String {
        switch self {
        case .book: return "book.closed.fill"
        case .drama: return "theatermasks.fill"
        case .location: return "mappin.and.ellipse"
        case .movie: return "film.fill"
        case .music: return "music.note"
        case .other: return "sparkles"
        }
    }
}

private extension CLLocationCoordinate2D {
    var displayText: String {
        "\(formattedLongitude), \(formattedLatitude)"
    }

    var copyText: String {
        "\(longitude), \(latitude)"
    }

    private var formattedLongitude: String {
        "\(abs(longitude).formatted(.number.precision(.fractionLength(5))))° \(longitude >= 0 ? "E" : "W")"
    }

    private var formattedLatitude: String {
        "\(abs(latitude).formatted(.number.precision(.fractionLength(5))))° \(latitude >= 0 ? "N" : "S")"
    }
}
