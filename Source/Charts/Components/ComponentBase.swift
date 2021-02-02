//
//  ComponentBase.swift
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

/// This class encapsulates everything both Axis, Legend and LimitLines have in common
open class ComponentBase {
    /// flag that indicates if this component is enabled or not
    open var enabled = true

    /// The offset this component has on the x-axis
    /// **default**: 5.0
    open var xOffset = CGFloat(5.0)

    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    open var yOffset = CGFloat(5.0)

    public init() {}

    open var isEnabled: Bool { return enabled }
}
