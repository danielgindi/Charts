//
//  AxisBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

/// Base class for all axes
@objc(ChartAxisBase)
open class AxisBase: ComponentBase
{
    public override init()
    {
        super.init()
    }
    
    /// Custom formatter that is used instead of the auto-formatter if set
    private var _axisValueFormatter: AxisValueFormatter?
    
    @objc open var labelFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var labelTextColor = NSUIColor.black
    
    @objc open var axisLineColor = NSUIColor.gray
    @objc open var axisLineWidth: CGFloat = 0.5
    @objc open var axisLineDashPhase: CGFloat = 0.0
    @objc open var axisLineDashLengths: [CGFloat]!
    
    @objc open var gridColor = NSUIColor.gray.withAlphaComponent(0.9)
    @objc open var gridLineWidth: CGFloat = 0.5
    @objc open var gridLineDashPhase: CGFloat = 0.0
    @objc open var gridLineDashLengths: [CGFloat]!
    @objc open var gridLineCap = CGLineCap.butt
    
    @objc open var isDrawGridLinesEnabled = true
    @objc open var isDrawAxisLineEnabled = true
    
    /// flag that indicates of the labels of this axis should be drawn or not
    @objc open var isDrawLabelsEnabled = true

    /// Centers the axis labels instead of drawing them at their original position.
    /// This is useful especially for grouped BarChart.
    @objc open var isCenterAxisLabelsEnabled: Bool
    {
        get { return _isCenterAxisLabelsEnabled && entryCount > 0 }
        set { _isCenterAxisLabelsEnabled = newValue }
    }
    private var _isCenterAxisLabelsEnabled = false

    /// array of limitlines that can be set for the axis
    @objc open private(set) var limitLines = [ChartLimitLine]()
    
    /// Are the LimitLines drawn behind the data or in front of the data?
    /// 
    /// **default**: false
    @objc open var isDrawLimitLinesBehindDataEnabled = false

    /// the flag can be used to turn off the antialias for grid lines
    @objc open var gridAntialiasEnabled = true
    
    /// the actual array of entries
    @objc open var entries = [Double]()
    
    /// axis label entries only used for centered labels
    @objc open var centeredEntries = [Double]()
    
    /// the number of entries the legend contains
    @objc open var entryCount: Int { return entries.count }
    
    /// the number of label entries the axis should have
    ///
    /// **default**: 6
    private var _labelCount = 6
    
    /// the number of decimal digits to use (for the default formatter
    @objc open var decimals: Int = 0
    
    /// When true, axis labels are controlled by the `granularity` property.
    /// When false, axis values could possibly be repeated.
    /// This could happen if two adjacent axis values are rounded to same value.
    /// If using granularity this could be avoided by having fewer axis values visible.
    @objc open var isGranularityEnabled = false
    
    /// The minimum interval between axis values.
    /// This can be used to avoid label duplicating when zooming in.
    ///
    /// **default**: 1.0
    @objc open private(set) var granularity = 1.0
    {
        didSet
        {
            // set this to `true` if it was disabled, as it makes no sense to set this property with granularity disabled
            isGranularityEnabled = true
        }
    }

    /// if true, the set number of y-labels will be forced
    @objc open var isForceLabelsEnabled = false
    
    @objc open func getLongestLabel() -> String
    {
        return entries.indices.reduce(into: "") { longest, i in
            let test = getFormattedLabel(i)
            longest = test.count > longest.count ? test : longest
        }
    }
    
    /// - returns: The formatted label at the specified index. This will either use the auto-formatter or the custom formatter (if one is set).
    @objc open func getFormattedLabel(_ index: Int) -> String
    {
        guard entries.indices.contains(index) else { return "" }
        return valueFormatter?.stringForValue(entries[index], axis: self) ?? ""
    }
    
    /// Sets the formatter to be used for formatting the axis labels.
    /// If no formatter is set, the chart will automatically determine a reasonable formatting (concerning decimals) for all the values that are drawn inside the chart.
    /// Use `nil` to use the formatter calculated by the chart.
    @objc open var valueFormatter: AxisValueFormatter?
    {
        get
        {
            if _axisValueFormatter == nil ||
                (_axisValueFormatter is DefaultAxisValueFormatter &&
                    (_axisValueFormatter as! DefaultAxisValueFormatter).hasAutoDecimals &&
                    (_axisValueFormatter as! DefaultAxisValueFormatter).decimals != decimals)
            {
                _axisValueFormatter = DefaultAxisValueFormatter(decimals: decimals)
            }
            
            return _axisValueFormatter
        }
        set
        {
            _axisValueFormatter = newValue ?? DefaultAxisValueFormatter(decimals: decimals)
        }
    }

    /// Extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
    @objc open var spaceMin = 0.0
    
    /// Extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
    @objc open var spaceMax = 0.0
    
    /// Flag indicating that the axis-min value has been customized
    var useCustomAxisMin = false
    
    /// Flag indicating that the axis-max value has been customized
    var useCustomAxisMax = false
    
    /// Do not touch this directly, instead, use axisMinimum.
    /// This is automatically calculated to represent the real min value,
    /// and is used when calculating the effective minimum.
    var _axisMinimum = 0.0
    
    /// Do not touch this directly, instead, use axisMaximum.
    /// This is automatically calculated to represent the real max value,
    /// and is used when calculating the effective maximum.
    var _axisMaximum = 0.0
    
    /// the total range of values this axis covers
    @objc open var axisRange = 0.0
    
    /// the number of label entries the axis should have
    /// max = 25,
    /// min = 2,
    /// default = 6,
    /// be aware that this number is not fixed and can only be approximated
    @objc open var labelCount: Int
    {
        get
        {
            return _labelCount
        }
        set
        {
            switch newValue
            {
            case ...2: _labelCount = 2
            case 25...: _labelCount = 25
            default: _labelCount = newValue
            }

            isForceLabelsEnabled = false
        }
    }
    
    @objc open func setLabelCount(_ count: Int, force: Bool)
    {
        labelCount = count
        isForceLabelsEnabled = force
    }

    /// Adds a new ChartLimitLine to this axis.
    @objc open func addLimitLine(_ line: ChartLimitLine)
    {
        limitLines.append(line)
    }
    
    /// Removes the specified ChartLimitLine from the axis.
    @objc open func removeLimitLine(_ line: ChartLimitLine)
    {
        guard let i = limitLines.index(of: line) else { return }
        limitLines.remove(at: i)
    }
    
    /// Removes all LimitLines from the axis.
    @objc open func removeAllLimitLines()
    {
        limitLines.removeAll(keepingCapacity: false)
    }
    
    // MARK: Custom axis ranges
    
    /// By calling this method, any custom minimum value that has been previously set is reseted, and the calculation is done automatically.
    @objc open func resetCustomAxisMin()
    {
        useCustomAxisMin = false
    }

    /// By calling this method, any custom maximum value that has been previously set is reseted, and the calculation is done automatically.
    @objc open func resetCustomAxisMax()
    {
        useCustomAxisMax = false
    }

    /// The minimum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMin()` to undo this.
    @objc open var axisMinimum: Double
    {
        get
        {
            return _axisMinimum
        }
        set
        {
            useCustomAxisMin = true
            _axisMinimum = newValue
            axisRange = abs(_axisMaximum - newValue)
        }
    }
    
    /// The maximum value for this axis.
    /// If set, this value will not be calculated automatically depending on the provided data.
    /// Use `resetCustomAxisMax()` to undo this.
    @objc open var axisMaximum: Double
    {
        get
        {
            return _axisMaximum
        }
        set
        {
            useCustomAxisMax = true
            _axisMaximum = newValue
            axisRange = abs(newValue - _axisMinimum)
        }
    }
    
    /// Calculates the minimum, maximum and range values of the YAxis with the given minimum and maximum values from the chart data.
    /// - parameter dataMin: the y-min value according to chart data
    /// - parameter dataMax: the y-max value according to chart
    @objc open func calculate(min dataMin: Double, max dataMax: Double)
    {
        // if custom, use value as is, else use data value
        var min = useCustomAxisMin ? _axisMinimum : (dataMin - spaceMin)
        var max = useCustomAxisMax ? _axisMaximum : (dataMax + spaceMax)
        
        // temporary range (before calculations)
        let range = abs(max - min)
        
        // in case all values are equal
        if range == 0.0
        {
            max = max + 1.0
            min = min - 1.0
        }
        
        _axisMinimum = min
        _axisMaximum = max
        
        // actual range
        axisRange = abs(max - min)
    }
}
