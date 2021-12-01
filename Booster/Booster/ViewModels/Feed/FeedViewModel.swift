//
//  FeedViewModel.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation
import RxSwift
import RxRelay

typealias FeedCellConfigure = CollectionCellConfigurator<FeedCell, (date: Date,
                                                                    distance: Double,
                                                                    step: Int,
                                                                    title: String,
                                                                    imageData: Data,
                                                                    isEmpty: Bool)>

final class FeedViewModel {
    subscript(indexPath: IndexPath) -> CellConfigurator {
        let isEmpty = recordCount() == 0
        return FeedCellConfigure(item: (date: isEmpty ? Date() : list.value[indexPath.row].startDate,
                                        distance: isEmpty ? 0 : list.value[indexPath.row].distance,
                                        step: isEmpty ? 0 : list.value[indexPath.row].steps,
                                        title: isEmpty ? "" : list.value[indexPath.row].title,
                                        imageData: isEmpty ? Data() : list.value[indexPath.row].imageData,
                                        isEmpty: isEmpty))
    }

    private let disposeBag = DisposeBag()
    private let usecase = FeedUseCase()
    private(set) var list = BehaviorRelay<[FeedList]>(value: [])
    let next = PublishSubject<Date>()
    let select = PublishSubject<IndexPath>()

    init() {
        bind()
    }

    func recordCount() -> Int {
        return list.value.count
    }

    private func bind() {
        select.observe(on: MainScheduler.instance)
            .filter { _ in self.recordCount() > 0 }
            .map { (index) -> Date in
                return self.list.value[index.row].startDate
            }.bind { [weak self] value in
                if let count = self?.recordCount(),
                   count != 0 {
                    self?.next.onNext(value)
                }
            }.disposed(by: disposeBag)
    }

    func fetch() {
        usecase.fetch()
            .map { (values) -> [FeedList] in
                return values.reversed()
            }.subscribe(onSuccess: { [weak self] values in
                self?.list.accept(values)
            }).disposed(by: disposeBag)
    }
}
