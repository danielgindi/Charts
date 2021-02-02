//
//  BarChartDataProvider.swift
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

public protocol BarChartDataProvider: BarLineScatterCandleBubbleChartDataProvider {
    var barData: BarChartData? { get }

    var isDrawBarShadowEnabled: Bool { get }
    var isDrawValueAboveBarEnabled: Bool { get }
    var isHighlightFullBarEnabled: Bool { get }
}
