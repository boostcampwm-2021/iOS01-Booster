import Foundation

struct StatisticsCollection {

    private var statisticsCollection: [Statistics] = []
    var count: Int { statisticsCollection.count }

    subscript (index: Int) -> Statistics {
        statisticsCollection[index]
    }

    func statistics() -> [Statistics] {
        statisticsCollection
    }

    func maxStatistics() -> Statistics? {
        guard var maxStatistics = statisticsCollection.first else { return nil }
        for statistics in statisticsCollection {
            if maxStatistics.step < statistics.step { maxStatistics = statistics }
        }
        return maxStatistics
    }

    func averageStatistics() -> Int {
        var average = 0
        for statistics in statisticsCollection {
            average += statistics.step
        }
        return average/self.count
    }

    mutating func append(statistics: Statistics) {
        self.statisticsCollection.append(statistics)
    }
}

struct Statistics {
    let date: Date
    let step: Int
}
