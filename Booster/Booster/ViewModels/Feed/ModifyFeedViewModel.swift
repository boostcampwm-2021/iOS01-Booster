//
//  ModifyFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/23.
//

import Foundation
import RxSwift
import RxRelay
// import RxRelay

final class ModifyFeedViewModel {
    // MARK: - Properties
    var isUpdated = PublishSubject<Bool>()
    var writingRecord: BehaviorRelay<WritingRecord>
    private let startDate: Date
    private let usecase: ModifyFeedUsecaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(startDate: Date, writingRecord: WritingRecord, usecase: ModifyFeedUsecaseProtocol) {
        self.startDate = startDate
        self.writingRecord = BehaviorRelay<WritingRecord>(value: writingRecord)
        self.usecase = usecase
    }

    // MARK: - Functions
    func update() {
        let predicate = NSPredicate(format: "startDate = %@", startDate as NSDate)
        usecase.update(model: writingRecord.value, predicate: predicate)
            .subscribe(onError: { _ in
                self.isUpdated.onNext(false)
            }, onCompleted: {
                self.isUpdated.onNext(true)
            })
            .disposed(by: disposeBag)
    }

    func modifyTitle(_ title: String) {
        writingRecord.accept(WritingRecord(title: title, content: writingRecord.value.content))
    }

    func modifyContent(_ content: String) {
        writingRecord.accept(WritingRecord(title: writingRecord.value.title, content: content))
    }
}
