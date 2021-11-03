import Foundation

final class TrackingProgressViewModel {
    private(set) var trackingModel: TrackingModel
    private(set) var user: User
    private(set) var state: TrackingState
    
    init(trackingModel: TrackingModel, user: User){
        self.trackingModel = trackingModel
        self.user = user
        self.state = .start
    }
    
    func append(coordinate: Coordinate?) {
        
    }
    
    func append(mileStoe: MileStone) {
        
    }
    
    func appends(coordinates: [Coordinate?]) {
        
    }
    
    func appends(mileStones: [MileStone]) {
        
    }
    
    func recordEnd() {
        
    }
    
    func write(title: String) {
        
    }
    
    func write(content: String) {
        
    }
    
    func update(seconds: Int) {
        
    }
    
    func update(steps: Int) {
        
    }
    
    func update(distance: Double) {
        
    }
    
    func toggle() {
        
    }
}
