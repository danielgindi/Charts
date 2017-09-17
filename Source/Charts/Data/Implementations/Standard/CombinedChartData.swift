//
//  CombinedChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class CombinedChartData: BarLineScatterCandleBubbleChartData
{
    fileprivate var _lineData: LineChartData!
    fileprivate var _barData: BarChartData!
    fileprivate var _scatterData: ScatterChartData!
    fileprivate var _candleData: CandleChartData!
    fileprivate var _bubbleData: BubbleChartData!
    
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    open var lineData: LineChartData!
    {
        get
        {
            return _lineData
        }
        set
        {
            _lineData = newValue
            notifyDataChanged()
        }
    }
    
    open var barData: BarChartData!
    {
        get
        {
            return _barData
        }
        set
        {
            _barData = newValue
            notifyDataChanged()
        }
    }
    
    open var scatterData: ScatterChartData!
    {
        get
        {
            return _scatterData
        }
        set
        {
            _scatterData = newValue
            notifyDataChanged()
        }
    }
    
    open var candleData: CandleChartData!
    {
        get
        {
            return _candleData
        }
        set
        {
            _candleData = newValue
            notifyDataChanged()
        }
    }
    
    open var bubbleData: BubbleChartData!
    {
        get
        {
            return _bubbleData
        }
        set
        {
            _bubbleData = newValue
            notifyDataChanged()
        }
    }
    
    open override func calcMinMax()
    {
        _dataSets.removeAll()
        
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            let sets = data.dataSets
            _dataSets.append(contentsOf: sets)

            _xMax = max(data.xMax, _xMax)
            _xMin = min(data.xMin, _xMin)

            _leftAxisMax = max(data.yMax, _leftAxisMax)
            _leftAxisMin = min(data.yMin, _leftAxisMin)
            _rightAxisMax = max(data.yMax, _rightAxisMax)
            _rightAxisMin = min(data.yMin, _rightAxisMin)
        }
    }
    
    /// - returns: All data objects in row: line-bar-scatter-candle-bubble if not null.
    open var allData: [ChartData]
    {
        var data = [ChartData]()
        
        if lineData != nil
        {
            data.append(lineData)
        }
        if barData != nil
        {
            data.append(barData)
        }
        if scatterData != nil
        {
            data.append(scatterData)
        }
        if candleData != nil
        {
            data.append(candleData)
        }
        if bubbleData != nil
        {
            data.append(bubbleData)
        }
        
        return data
    }
    
    open func dataByIndex(_ index: Int) -> ChartData
    {
        return allData[index]
    }
    
    open func dataIndex(_ data: ChartData) -> Int?
    {
        return allData.index(of: data)
    }
    
    open override func removeDataSet(_ dataSet: IChartDataSet) -> Bool
    {
        let data = allData
        return data.contains { $0.removeDataSet(dataSet) }
    }
    
    open override func removeDataSetByIndex(_ index: Int) -> Bool
    {
        print("removeDataSet(index) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func removeEntry(_ entry: ChartDataEntry, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(entry, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func removeEntry(xValue: Double, dataSetIndex: Int) -> Bool
    {
        print("removeEntry(xValue, dataSetIndex) not supported for CombinedData", terminator: "\n")
        return false
    }
    
    open override func notifyDataChanged()
    {
        if _lineData != nil
        {
            _lineData.notifyDataChanged()
        }
        if _barData != nil
        {
            _barData.notifyDataChanged()
        }
        if _scatterData != nil
        {
            _scatterData.notifyDataChanged()
        }
        if _candleData != nil
        {
            _candleData.notifyDataChanged()
        }
        if _bubbleData != nil
        {
            _bubbleData.notifyDataChanged()
        }
        
        super.notifyDataChanged() // recalculate everything
    }
    
    /// Get the Entry for a corresponding highlight object
    ///
    /// - parameter highlight:
    /// - returns: The entry that is highlighted
    open override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry?
    {
        let dataObjects = allData
        
        guard highlight.dataIndex < allData.endIndex else { return nil }

        let data = dataObjects[highlight.dataIndex]
        
        guard highlight.dataSetIndex < data.dataSetCount else { return nil }
        // The value of the highlighted entry could be NaN - if we are not interested in highlighting a specific value.
        let entries = data.getDataSetByIndex(highlight.dataSetIndex).entriesForXValue(highlight.x)
        return entries.first { $0.y == highlight.y || highlight.y.isNaN }
    }
    
    /// Get dataset for highlight
    ///
    /// - Parameter highlight: current highlight
    /// - Returns: dataset related to highlight
    open func getDataSetByHighlight(_ highlight: Highlight) -> IChartDataSet!
    {  
        if highlight.dataIndex >= allData.count
        {
            return nil
        }
        
        let data = dataByIndex(highlight.dataIndex)
        
        if highlight.dataSetIndex >= data.dataSetCount
        {
            return nil
        }
        
        return data.dataSets[highlight.dataSetIndex]
    }
}
