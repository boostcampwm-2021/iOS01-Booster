import Foundation

struct StatisticsCollection: Equatable {
    private var statisticsCollection = [Statistics]()
    var count: Int { statisticsCollection.count }

    subscript (index: Int) -> Statistics {
        statisticsCollection[index]
    }

    func statistics() -> [Statistics] {
        statisticsCollection
    }

    func maxStatistics() -> Statistics? {
        guard var maxStatistics = statisticsCollection.first
        else { return nil }
        
        for statistics in statisticsCollection {
            maxStatistics = max(maxStatistics, statistics)
        }

        return maxStatistics
    }

    func averageStatistics() -> Int {
        guard let startDate = statisticsCollection.first?.date,
              let endDate = statisticsCollection.last?.date
        else { return 0 }

        let startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        let endDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate)

        let days = Calendar.current.dateComponents([.day], from: startDateComponents, to: endDateComponents).day ?? 1

        let sumStep = statisticsCollection.reduce(0) { $0 + $1.step }

        return sumStep / days
    }
    
    func termOfStatistics(component: Calendar.Component) -> String {
        guard let startDate = statisticsCollection.first?.date,
              let endDate = statisticsCollection.last?.date,
              let lastDate = Calendar.current.date(byAdding: component, value: 1, to: endDate)
        else { return String() }

        let startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
        let endDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: lastDate)

        guard let startYear = startDateComponents.year,
              let startMonth = startDateComponents.month,
              let startDay = startDateComponents.day,
              let endYear = endDateComponents.year,
              let endMonth = endDateComponents.month,
              let endDay = endDateComponents.day
        else { return String() }

        let startString = "\(startYear)년 \(startMonth)월 \(startDay)일"
        var endString = ""

        if startDateComponents.year != endDateComponents.year {
            endString = "\(endYear)년 \(endMonth)월 \(endDay)일"
        } else if startDateComponents.month != endDateComponents.month {
            endString = "\(endMonth)월 \(endDay)일"
        } else {
            endString = "\(endDay)일"
        }

        return "\(startString) - \(endString)"
    }

    mutating func append(statistics: Statistics) {
        statisticsCollection.append(statistics)
    }

}

struct Statistics: Comparable {
    let date: Date
    let step: Int

    static func < (lhs: Statistics, rhs: Statistics) -> Bool {
        lhs.step < rhs.step
    }
}
