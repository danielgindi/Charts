//
//  PieChartDataEntry.swift
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

open class PieChartDataEntry: ChartDataEntry {
    public required init() {
        super.init()
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    public init(value: Double) {
        super.init(x: .nan, y: value)
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    public convenience init(value: Double, label: String?) {
        self.init(value: value)
        self.label = label
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - data: Spot for additional data this Entry represents
    public convenience init(value: Double, label: String?, data: Any?) {
        self.init(value: value, label: label, icon: nil, data: data)
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - icon: icon image
    public convenience init(value: Double, label: String?, icon: NSUIImage?) {
        self.init(value: value)
        self.label = label
        self.icon = icon
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - label: The label for the x-axis
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents
    public convenience init(value: Double, label: String?, icon: NSUIImage?, data: Any?) {
        self.init(value: value)
        self.label = label
        self.icon = icon
        self.data = data
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - data: Spot for additional data this Entry represents
    public convenience init(value: Double, data: Any?) {
        self.init(value: value)
        self.data = data
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - icon: icon image
    public convenience init(value: Double, icon: NSUIImage?) {
        self.init(value: value)
        self.icon = icon
    }

    /// - Parameters:
    ///   - value: The value on the y-axis
    ///   - icon: icon image
    ///   - data: Spot for additional data this Entry represents
    public convenience init(value: Double, icon: NSUIImage?, data: Any?) {
        self.init(value: value)
        self.icon = icon
        self.data = data
    }

    // MARK: Data property accessors

    open var label: String?

    open var value: Double {
        get { return y }
        set { y = newValue }
    }

    // MARK: NSCopying

    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! PieChartDataEntry
        copy.label = label
        return copy
    }
}
