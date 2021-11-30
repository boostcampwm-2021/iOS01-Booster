//
//  NWPathMonitor+Extension.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/30.
//

import Network
import RxSwift

extension NWPathMonitor {
  var rx: Observable<NWPath> {
    Observable.create { [weak self] observer in
      self?.pathUpdateHandler = { path in
        observer.onNext(path)
      }
      self?.start(queue: DispatchQueue.global())
      return Disposables.create { self?.cancel() }
    }
  }
}
