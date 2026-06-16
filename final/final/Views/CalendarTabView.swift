import SwiftData
import SwiftUI

struct CalendarTabView: View {
    @Query(sort: \Review.watched, order: .forward) private var reviews: [Review]
    @State private var displayedMonth = Date.now

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthHeader
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                            Text(symbol)
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }

                        ForEach(daysInMonth) { day in
                            CalendarDayCell(day: day, reviews: reviewsForDay(day.date), isToday: calendar.isDateInToday(day.date))
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("日曆")
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(displayedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.title3.bold())

            Spacer()

            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var daysInMonth: [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))
        else {
            return []
        }

        var days: [CalendarDay] = []
        var cursor = firstWeek.start

        while cursor < lastWeek.end {
            let inMonth = calendar.isDate(cursor, equalTo: displayedMonth, toGranularity: .month)
            days.append(CalendarDay(date: cursor, isInDisplayedMonth: inMonth))
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }

        return days
    }

    private func reviewsForDay(_ date: Date) -> [Review] {
        reviews.filter { calendar.isDate($0.watched, inSameDayAs: date) }
    }
}

struct CalendarDayCell: View {
    let day: CalendarDay
    let reviews: [Review]
    let isToday: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(day.date.formatted(.dateTime.day()))
                .font(.subheadline.bold())
                .foregroundStyle(day.isInDisplayedMonth ? .primary : .secondary)
                .padding(6)
                .background(isToday ? Color.accentColor.opacity(0.18) : .clear, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                ForEach(reviews.prefix(3)) { review in
                    NavigationLink {
                        ReviewDetailView(review: review)
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(review.target?.type.color ?? .gray)
                                .frame(width: 8, height: 8)
                            Text(review.target?.name ?? "未命名")
                                .font(.caption2)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(minHeight: 94, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(day.isInDisplayedMonth ? Color.secondary.opacity(0.08) : Color.secondary.opacity(0.03))
        )
    }
}
