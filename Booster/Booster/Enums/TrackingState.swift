import Foundation

enum TrackingState {
    case start
    case pause
    case end

    mutating func toggle(to: TrackingState) {
        self = to
    }
}
