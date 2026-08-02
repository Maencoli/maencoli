import Foundation

/// Groups highlights that have not been assigned to a book yet by ISO week,
/// so the shelf can show a "2026년 32주" style pseudo-book for that week.
enum ISOWeekHelper {
    static func isoYearAndWeek(for date: Date, calendar: Calendar = .isoWeekCalendar) -> (year: Int, week: Int) {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return (components.yearForWeekOfYear ?? 0, components.weekOfYear ?? 0)
    }

    /// Stable identifier for a given date's ISO week, used to group Highlights.
    static func groupKey(for date: Date) -> String {
        let (year, week) = isoYearAndWeek(for: date)
        return "\(year)-W\(week)"
    }

    static func displayTitle(for date: Date, locale: Locale = .current) -> String {
        let (year, week) = isoYearAndWeek(for: date)
        if locale.language.languageCode?.identifier == "ko" {
            return "\(year)년 \(week)주"
        } else {
            return "Week \(week), \(year)"
        }
    }
}

extension Calendar {
    static var isoWeekCalendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.minimumDaysInFirstWeek = 4
        calendar.firstWeekday = 2
        return calendar
    }
}
