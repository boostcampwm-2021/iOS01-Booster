//
//  InfoPickerView.swift
//  Booster
//
//  Created by 김태훈 on 2021/11/16.
//

import UIKit

typealias PickerInfoType = InfoPickerView.Info

final class InfoPickerView: UIPickerView {
    enum Info {
        case age, height, weight

        var range: ClosedRange<Int> {
            switch self {
            case .age: return 10...100
            case .height: return 90...230
            case .weight: return 40...150
            }
        }
        var startRow: Int {
            switch self {
            case .age: return 14
            case .height: return 59
            case .weight: return 19
            }
        }
        var unit: String {
            switch self {
            case .age: return ""
            case .height: return "cm"
            case .weight: return "kg"
            }
        }
    }

    private var type: Info = .age
    private lazy var pickerData: [String] = {
        return Array(type.range.lowerBound...type.range.upperBound).map { "\($0)" }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        UIConfigure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        UIConfigure()
    }

    convenience init(frame: CGRect, type: Info) {
        self.init(frame: frame)
        self.type = type
        configure()
        selectRow(type.startRow, inComponent: 0, animated: false)
        reloadAllComponents()
    }

    private func UIConfigure() {
        backgroundColor = .boosterLabel
    }

    private func configure() {
        dataSource = self
        delegate = self
    }
}

extension InfoPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}

 extension InfoPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row], attributes: [
            .font: UIFont.notoSansKR(.regular, 35),
            .foregroundColor: UIColor.boosterBlackLabel
        ])
    }

     func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
         return 54
     }
 }
