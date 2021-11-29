//
//  NWPathMonitor+Extension.swift
//  Booster
//
//  Created by hiju on 2021/11/29.
//

import Foundation
import RxSwift
import Network

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
