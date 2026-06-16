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
                            .foregroundStyle(.secondary)

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
                            .foregroundStyle(.orange)
                    }
                    .font(.headline)

                    Text(DateFormatter.reviewDate.string(from: review.watched))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

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
                .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.secondary.opacity(0.12))
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
            VStack(alignment: .leading, spacing: 24) {
                if !target.photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(target.photos.enumerated()), id: \.offset) { index, attachment in
                                Button {
                                    selectedPhotoIndex = index
                                } label: {
                                    if let image = UIImage(data: attachment.data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 260, height: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else {
                    Image(.placeholder)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(target.name)
                        .font(.title.bold())

                    Text(target.type.title)
                        .font(.headline)
                        .foregroundStyle(target.type.color)

                    if let descriptions = (target.descriptions ?? "").nilIfEmpty {
                        Text(descriptions)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(target.attributes) { attribute in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attribute.type.title)
                                .font(.subheadline.bold())
                            Text(attribute.formattedValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.secondary.opacity(0.12))
                }
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
