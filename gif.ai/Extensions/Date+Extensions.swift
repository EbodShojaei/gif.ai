import Foundation

extension Date {
    var isWithinLastWeek: Bool {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return self > oneWeekAgo
    }
}
