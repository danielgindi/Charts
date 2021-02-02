//
//  RadarChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

open class RadarChartDataEntry: ChartDataEntry {
    public required init() {
        super.init()
    }

    /// - Parameters:
    ///   - value: The value on the y-axis.
    public init(value: Double) {
        super.init(x: .nan, y: value)
    }

    /// - Parameters:
    ///   - value: The value on the y-axis.
    ///   - data: Spot for additional data this Entry represents.
    public convenience init(value: Double, data: Any?) {
        self.init(value: value)
        self.data = data
    }

    // MARK: Data property accessors

    open var value: Double {
        get { return y }
        set { y = newValue }
    }

    // MARK: NSCopying

    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! RadarChartDataEntry

        return copy
    }
}
