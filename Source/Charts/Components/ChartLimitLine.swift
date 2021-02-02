//
//  ChartLimitLine.swift
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

/// The limit line is an additional feature for all Line, Bar and ScatterCharts.
/// It allows the displaying of an additional line in the chart that marks a certain maximum / limit on the specified axis (x- or y-axis).
open class ChartLimitLine: ComponentBase {
    public enum LabelPosition: Int {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }

    /// limit / maximum (the y-value or xIndex)
    open var limit = Double(0.0)

    private var _lineWidth = CGFloat(2.0)
    open var lineColor = NSUIColor(red: 237.0 / 255.0, green: 91.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
    open var lineDashPhase = CGFloat(0.0)
    open var lineDashLengths: [CGFloat]?

    open var valueTextColor = NSUIColor.labelOrBlack
    open var valueFont = NSUIFont.systemFont(ofSize: 13.0)

    open var drawLabelEnabled = true
    open var label = ""
    open var labelPosition = LabelPosition.rightTop

    override public init() {
        super.init()
    }

    public init(limit: Double) {
        super.init()
        self.limit = limit
    }

    public init(limit: Double, label: String) {
        super.init()
        self.limit = limit
        self.label = label
    }

    /// set the line width of the chart (min = 0.2, max = 12); default 2
    open var lineWidth: CGFloat {
        get {
            return _lineWidth
        }
        set {
            _lineWidth = newValue.clamped(to: 0.2 ... 12)
        }
    }
}
