//
//  BaseViewControllerProtocol.swift
//  Booster
//
//  Created by mong on 2021/11/10.
//

import Foundation

protocol BaseViewControllerTemplate {
    associatedtype ViewModelType
    var viewModel: ViewModelType { get set }
    func configure()
}

extension BaseViewControllerTemplate {
    func configure() {}
}
