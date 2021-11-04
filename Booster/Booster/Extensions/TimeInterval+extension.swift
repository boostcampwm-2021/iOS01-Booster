//
//  TimeInterval+extension.swift
//  Booster
//
//  Created by hiju on 2021/11/03.
//

import Foundation

extension TimeInterval {
    private var seconds: Int {
        return Int(self) % 60
    }

    private var minutes: Int {
        return (Int(self) / 60) % 60
    }

    private var hours: Int {
        return Int(self) / 3600
    }

    func stringToMinutesAndSeconds() -> String {
        return "\(hours)h \(minutes)m"
    }
}
