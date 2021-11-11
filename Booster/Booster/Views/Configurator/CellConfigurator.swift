//
//  CellConfigurator.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/10.
//

import UIKit

protocol ConfigurableCell {
    associatedtype DataType
    func configure(data: DataType)
}

protocol CellConfigurator {
    static var reuseId: String { get }
    func configure(cell: UIView)
}

class CollectionCellConfigurator<CellType: ConfigurableCell, DataType>: CellConfigurator where CellType.DataType == DataType, CellType: UICollectionViewCell {
    static var reuseId: String { return String(describing: CellType.self) }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UIView) {
        guard let view = cell as? CellType else { return }
        view.configure(data: item)
    }
}

class ReuseableViewConfigurator<ViewType: ConfigurableCell, DataType>: CellConfigurator where ViewType.DataType == DataType, ViewType: UICollectionReusableView {
    static var reuseId: String { return String(describing: ViewType.self) }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UIView) {
        guard let view = cell as? ViewType else { return }
        view.configure(data: item)
    }
}
