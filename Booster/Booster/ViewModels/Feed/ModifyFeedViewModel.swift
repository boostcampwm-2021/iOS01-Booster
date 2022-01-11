//
//  ModifyFeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/23.
//

import Foundation
import RxSwift
import RxRelay

final class ModifyFeedViewModel {
    // MARK: - Properties
    var isUpdated = PublishSubject<Bool>()
    var writingRecord: BehaviorRelay<WritingRecord>
    private let startDate: Date
    private let usecase = ModifyFeedUsecase()
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(startDate: Date, writingRecord: WritingRecord) {
        self.startDate = startDate
        self.writingRecord = BehaviorRelay<WritingRecord>(value: writingRecord)
    }

    // MARK: - Functions
    func update() {
        let predicate = NSPredicate(format: "startDate = %@", startDate as NSDate)
        usecase.update(model: writingRecord.value, predicate: predicate)
            .subscribe { [weak self] result in
                switch result {
                case .success:
                    self?.isUpdated.onNext(true)
                case .failure:
                    self?.isUpdated.onNext(false)
                }
            }.disposed(by: disposeBag)
    }

    func modifyTitle(_ title: String) {
        writingRecord.accept(WritingRecord(title: title, content: writingRecord.value.content))
    }

    func modifyContent(_ content: String) {
        writingRecord.accept(WritingRecord(title: writingRecord.value.title, content: content))
    }
}
