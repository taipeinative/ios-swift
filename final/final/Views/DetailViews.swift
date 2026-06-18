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
                    NavigationLink {
                        TargetDetailView(target: target)
                    } label: {
                        ReviewTargetInfoCard(target: target)
                    }
                    .buttonStyle(.plain)
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
                                        AttachmentImage(attachment: attachment, contentMode: .fill, placeholderPadding: 28)
                                            .frame(width: 180, height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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

private struct ReviewTargetInfoCard: View {
    let target: Target

    private var descriptionText: String? {
        target.descriptions?.nilIfEmpty
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            AttachmentImage(attachment: target.primaryPhoto, contentMode: .fill, placeholderPadding: 14)
            .frame(width: 82, height: 82)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(target.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.primaryText)
                    .lineLimit(2)

                Text(target.summaryText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .lineLimit(1)

                if let descriptionText {
                    Text(descriptionText)
                        .font(.footnote)
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.shared.secondaryText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .contentShape(.interaction, RoundedRectangle(cornerRadius: 26, style: .continuous))
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

                TargetReviewsSection(target: target)
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
                        AttachmentImage(attachment: attachment, contentMode: .fill, placeholderPadding: 32)
                            .frame(maxWidth: .infinity)
                            .frame(height: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(target.photos.enumerated()), id: \.offset) { index, attachment in
                                Button {
                                    selectedPhotoIndex = index
                                } label: {
                                    AttachmentImage(attachment: attachment, contentMode: .fill, placeholderPadding: 32)
                                        .frame(width: 280, height: 240)
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
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
                        .padding(.bottom, 8)

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

private struct TargetReviewsSection: View {
    let target: Target

    @AppStorage(RatingStandard.key0To1) private var rating0To1 = ""
    @AppStorage(RatingStandard.key1To2) private var rating1To2 = ""
    @AppStorage(RatingStandard.key2To3) private var rating2To3 = ""
    @AppStorage(RatingStandard.key3To4) private var rating3To4 = ""
    @AppStorage(RatingStandard.key4To5) private var rating4To5 = ""
    @State private var selectedReviewCount: Int?

    private var sortedReviews: [Review] {
        target.reviews.sorted { lhs, rhs in
            if lhs.reviewCount == rhs.reviewCount {
                return lhs.watched > rhs.watched
            }
            return lhs.reviewCount < rhs.reviewCount
        }
    }

    private var reviewCountOptions: [Int] {
        Array(Set(target.reviews.map(\.reviewCount))).sorted()
    }

    private var visibleReviews: [Review] {
        guard let selectedReviewCount else { return sortedReviews }
        return sortedReviews.filter { $0.reviewCount == selectedReviewCount }
    }

    private var averageScoreText: String {
        guard !target.reviews.isEmpty else { return "尚未評分" }
        let average = target.reviews.map(\.score).reduce(0, +) / Double(target.reviews.count)
        return String(format: "%.1f   ", average)
    }

    private var ratingTexts: [String] {
        [rating0To1, rating1To2, rating2To3, rating3To4, rating4To5]
    }

    var body: some View {
        DetailSectionCard(title: "評論") {
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(alignment: .center) {
                    Text("平均評分")
                        .foregroundStyle(AppColors.shared.secondaryText)
                    Spacer()
                    Text(averageScoreText)
                }

                HStack {
                    Text("顯示評論")
                        .foregroundStyle(AppColors.shared.secondaryText)

                    Spacer()

                    Picker("顯示評論", selection: $selectedReviewCount) {
                        Text("全部").tag(Optional<Int>.none)

                        ForEach(reviewCountOptions, id: \.self) { count in
                            Text("第 \(count) 次評論").tag(Optional(count))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .pickerStyle(.menu)
                    .disabled(reviewCountOptions.isEmpty)
                    .tint(AppColors.shared.primaryText)
                }
                .padding(.bottom, 10)

                if visibleReviews.isEmpty {
                    Text("尚無評論內容")
                        .font(.body)
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 12) {
                        ForEach(visibleReviews) { review in
                            TargetReviewSummaryCard(
                                review: review,
                                ratingText: RatingStandard.text(for: review.score, customTexts: ratingTexts)
                            )
                        }
                    }
                }
            }
        }
    }
}

private struct TargetReviewSummaryCard: View {
    let review: Review
    let ratingText: String

    @Environment(\.modelContext) private var modelContext
    @State private var isShowingReviewDetail = false
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteAlert = false

    private var actionDateTitle: String {
        review.target?.type.actionDateTitle ?? "體驗日期"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    NavigationLink {
                        ReviewDetailView(review: review)
                    } label: {
                        HStack(spacing: 5) {
                            Text(ratingText)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                        .font(.headline)
                        .foregroundStyle(AppColors.shared.primaryText)
                    }
                    .buttonStyle(.plain)

                    Text("\(actionDateTitle)：\(DateFormatter.reviewDate.string(from: review.watched))")
                        .font(.caption)
                        .foregroundStyle(AppColors.shared.secondaryText)

                    Text("評論日期：\(DateFormatter.reviewDate.string(from: review.created))")
                        .font(.caption)
                        .foregroundStyle(AppColors.shared.secondaryText)
                }

                Spacer()

                Label(String(format: "%.1f 分", review.score), systemImage: "star.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.shared.score)
            }
            .padding(.bottom, 7)
            
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.body)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !review.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(review.photos.enumerated()), id: \.offset) { _, attachment in
                            AttachmentImage(attachment: attachment, contentMode: .fill, placeholderPadding: 18)
                                .frame(width: 112, height: 112)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.shared.standardStroke)
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contextMenu {
            Button {
                isShowingReviewDetail = true
            } label: {
                Label("查看", systemImage: "eye")
            }

            Button {
                isShowingEditSheet = true
            } label: {
                Label("編輯", systemImage: "square.and.pencil")
            }

            Button(role: .destructive) {
                isShowingDeleteAlert = true
            } label: {
                Label("刪除", systemImage: "trash")
            }
        }
        .navigationDestination(isPresented: $isShowingReviewDetail) {
            ReviewDetailView(review: review)
        }
        .sheet(isPresented: $isShowingEditSheet) {
            NavigationStack {
                ReviewFormView(mode: .edit(review: review))
            }
        }
        .alert("確定刪除這則評論嗎？", isPresented: $isShowingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                review.target?.reviews.removeAll { $0.id == review.id }
                modelContext.delete(review)
                try? modelContext.save()
            }
        } message: {
            Text("刪除後將無法復原。")
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
        VStack(alignment: .leading, spacing: 10) {
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
