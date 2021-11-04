import Foundation

final class Observable<T> {

    private var listener: ((T) -> Void)?

    var value: T {
        didSet {
            self.listener?(self.value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }

}
