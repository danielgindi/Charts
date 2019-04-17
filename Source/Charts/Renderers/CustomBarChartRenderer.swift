//
//  CustomBarChartRenderer.swift
//  medclinik.humagine.profile.crashlytics
//
//  Created by Oussama Ayed on 3/21/19.
//  Copyright © 2019 360medlink. All rights reserved.
//

import Foundation
import CoreGraphics

#if !os(OSX)
import UIKit
#endif
public class CustomBarChartRenderer: BarChartRenderer {
    fileprivate var _barShadowRectBuffer: CGRect = CGRect()
    fileprivate var _buffers = [Buffer]()
    fileprivate class Buffer
    {
        var rects = [CGRect]()
    }
    fileprivate func prepareBuffer(dataSet: IBarChartDataSet, index: Int)
    {
        
        if index < _buffers.count {
            guard let dataProvider = dataProvider, let barData = dataProvider.barData
            else { return }
            
            let barWidthHalf = barData.barWidth / 2.0
            
            let buffer = _buffers[index]
            var bufferIndex = 0
            let containsStacks = dataSet.isStacked
            
            let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
            let phaseY = animator.phaseY
            var barRect = CGRect()
            var x: Double
            var y: Double
            
            for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
            {
                guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
                
                let vals = e.yValues
                
                x = e.x
                y = e.y
                
                if !containsStacks || vals == nil
                {
                    let left = CGFloat(x - barWidthHalf)
                    let right = CGFloat(x + barWidthHalf)
                    var top = isInverted
                        ? (y <= 0.0 ? CGFloat(y) : 0)
                        : (y >= 0.0 ? CGFloat(y) : 0)
                    var bottom = isInverted
                        ? (y >= 0.0 ? CGFloat(y) : 0)
                        : (y <= 0.0 ? CGFloat(y) : 0)
                    
                    // multiply the height of the rect with the phase
                    if top > 0
                    {
                        top *= CGFloat(phaseY)
                    }
                    else
                    {
                        bottom *= CGFloat(phaseY)
                    }
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    buffer.rects[bufferIndex] = barRect
                    bufferIndex += 1
                }
                else
                {
                    var posY = 0.0
                    var negY = -e.negativeSum
                    var yStart = 0.0
                    
                    // fill the stack
                    for k in 0 ..< vals!.count
                    {
                        let value = vals![k]
                        
                        if value == 0.0 && (posY == 0.0 || negY == 0.0)
                        {
                            // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                            y = value
                            yStart = y
                        }
                        else if value >= 0.0
                        {
                            y = posY
                            yStart = posY + value
                            posY = yStart
                        }
                        else
                        {
                            y = negY
                            yStart = negY + abs(value)
                            negY += abs(value)
                        }
                        
                        let left = CGFloat(x - barWidthHalf)
                        let right = CGFloat(x + barWidthHalf)
                        var top = isInverted
                            ? (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                            : (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                        var bottom = isInverted
                            ? (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                            : (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                        
                        // multiply the height of the rect with the phase
                        top *= CGFloat(phaseY)
                        bottom *= CGFloat(phaseY)
                        
                        barRect.origin.x = left
                        barRect.size.width = right - left
                        barRect.origin.y = top
                        barRect.size.height = bottom - top
                        
                        buffer.rects[bufferIndex] = barRect
                        bufferIndex += 1
                    }
                }
            }
        }
    }
    
    open override func initBuffers()
    {
        if let barData = dataProvider?.barData
        {
            // Matche buffers count to dataset count
            if _buffers.count != barData.dataSetCount
            {
                while _buffers.count < barData.dataSetCount
                {
                    _buffers.append(Buffer())
                }
                while _buffers.count > barData.dataSetCount
                {
                    _buffers.removeLast()
                }
            }
            
            for i in stride(from: 0, to: barData.dataSetCount, by: 1)
            {
                let set = barData.dataSets[i] as! IBarChartDataSet
                let size = set.entryCount * (set.isStacked ? set.stackSize : 1)
                if _buffers[i].rects.count != size
                {
                    _buffers[i].rects = [CGRect](repeating: CGRect(), count: size)
                }
            }
        }
        else
        {
            _buffers.removeAll()
        }
    }
    
    
    public override func drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int) {

        guard let dataProvider = dataProvider else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)

        prepareBuffer(dataSet: dataSet, index: index)
        trans.rectValuesToPixel(&_buffers[index].rects)

        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0

        context.saveGState()

        // draw the bar shadow before the values
        if dataProvider.isDrawBarShadowEnabled
        {
            guard let barData = dataProvider.barData else { return }

            let barWidth = barData.barWidth
            let barWidthHalf = barWidth / 2.0
            var x: Double = 0.0

            for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
            {
                guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }

                x = e.x

                _barShadowRectBuffer.origin.x = CGFloat(x - barWidthHalf)
                _barShadowRectBuffer.size.width = CGFloat(barWidth)

                trans.rectValueToPixel(&_barShadowRectBuffer)

                if !viewPortHandler.isInBoundsLeft(_barShadowRectBuffer.origin.x + _barShadowRectBuffer.size.width)
                {
                    continue
                }

                if !viewPortHandler.isInBoundsRight(_barShadowRectBuffer.origin.x)
                {
                    break
                }

                _barShadowRectBuffer.origin.y = viewPortHandler.contentTop
                _barShadowRectBuffer.size.height = viewPortHandler.contentHeight

                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(_barShadowRectBuffer)
            }
        }

        let buffer = _buffers[index]

        // draw the bar shadow before the values
        if dataProvider.isDrawBarShadowEnabled
        {
            for j in stride(from: 0, to: buffer.rects.count, by: 1)
            {
                let barRect = buffer.rects[j]

                if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                {
                    continue
                }

                if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                {
                    break
                }

                context.setFillColor(dataSet.barShadowColor.cgColor)
                // Corner Radius for the bar charts
                 if (j % 4 == 0) {
                    // bottom of the bar chart
                    let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.bottomRight, .bottomLeft], cornerRadius: 5)
                        bezierPath.fill()
                }else if (j % 4 == 3 ){
                    //middle of the bar chart
                    let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.topLeft, .topRight], cornerRadius: 5)
                    bezierPath.fill()
                        //NSBezierPath(roundedRect: barRect, xRadius: [.topLeft, .topRight], yRadius: CGSize(width: 5.0, height: 0.0))

                    //context.addPath(bezierPath.cgPath)
                }else  {
                    //top of the bar chart
                    let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.bottomRight, .bottomLeft], cornerRadius: 5)
                    bezierPath.fill()
                        //NSBezierPath(roundedRect: barRect, xRadius: [.bottomRight, .bottomLeft], yRadius: CGSize(width: 0.0, height: 0.0))
                   // context.addPath(bezierPath.cgPath)
                }



                context.drawPath(using: .fill)
            }
        }

        let isSingleColor = dataSet.colors.count == 1

        if isSingleColor
        {
            context.setFillColor(dataSet.color(atIndex: 0).cgColor)
        }

        // In case the chart is stacked, we need to accomodate individual bars within accessibilityOrdereredElements
        let isStacked = dataSet.isStacked
        let stackSize = isStacked ? dataSet.stackSize : 1

        for j in stride(from: 0, to: buffer.rects.count, by: 1)
        {
            let barRect = buffer.rects[j]

            if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
            {
                continue
            }

            if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
            {
                break
            }

            if !isSingleColor
            {
                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                context.setFillColor(dataSet.color(atIndex: j).cgColor)
            }
            // Corner Radius for the bar charts
            if (j % 4 == 0) {
                // bottom of the bar chart
                let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.bottomRight, .bottomLeft], cornerRadius: 5)
                bezierPath.fill()
                    //UIBezierPath(roundedRect: barRect, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 5.0, height: 0.0))
               // context.addPath(bezierPath.cgPath)
            }else if (j % 4 == 3 ){
                //middle of the bar chart
                let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.topLeft, .topRight], cornerRadius: 5)
                bezierPath.fill()
                    //UIBezierPath(roundedRect: barRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5.0, height: 0.0))

             //   context.addPath(bezierPath.cgPath)
            }else{
                //top of the bar chart
                let bezierPath = NSBezierPath(rect: barRect, roundedCorners: [.bottomRight, .bottomLeft], cornerRadius: 5)
                bezierPath.fill()
                    //UIBezierPath(roundedRect: barRect, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 0.0, height: 0.0))
              //  context.addPath(bezierPath.cgPath)
            }

            context.drawPath(using: .fill)

            if drawBorder
            {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderWidth)
                context.stroke(barRect)
            }


            // Create and append the corresponding accessibility element to accessibilityOrderedElements
            if let chart = dataProvider as? BarChartView
            {
                let element = createAccessibleElement(withIndex: j,
                                                      container: chart,
                                                      dataSet: dataSet,
                                                      dataSetIndex: index,
                                                      stackSize: stackSize)
                { (element) in
                    element.accessibilityFrame = barRect
                }

               accessibilityOrderedElements[j/stackSize].append(element)
            }
        }



        context.restoreGState()

    }
    public override func drawValues(context: CGContext)
    {
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard
                let dataProvider = dataProvider,
                let barData = dataProvider.barData
                else { return }
            
            var dataSets = barData.dataSets
            
            let valueOffsetPlus: CGFloat = 4.5
            var posOffset: CGFloat
            var negOffset: CGFloat
            let drawValueAboveBar = dataProvider.isDrawValueAboveBarEnabled
            
            for dataSetIndex in 0 ..< barData.dataSetCount
            {
                guard let dataSet = dataSets[dataSetIndex] as? IBarChartDataSet else { continue }
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
                
                // calculate the correct offset depending on the draw position of the value
                let valueFont = dataSet.valueFont
                let valueTextHeight = valueFont.lineHeight
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))
                
                if isInverted
                {
                    posOffset = -posOffset - valueTextHeight
                    negOffset = -negOffset - valueTextHeight
                }
                
                let buffer = _buffers[dataSetIndex]
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                
                let phaseY = animator.phaseY
                
                let iconsOffset = dataSet.iconsOffset
                
                // if only single values are drawn (sum)
                if !dataSet.isStacked
                {
                    for j in 0 ..< Int(ceil(Double(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }
                        
                        let rect = buffer.rects[j]
                        
                        let x = rect.origin.x + rect.size.width / 2.0
                        
                        if !viewPortHandler.isInBoundsRight(x)
                        {
                            break
                        }
                        
                        if !viewPortHandler.isInBoundsY(rect.origin.y)
                            || !viewPortHandler.isInBoundsLeft(x)
                        {
                            continue
                        }
                        
                        let val = e.y
                        
                        if dataSet.isDrawValuesEnabled
                        {
                            drawValue(
                                context: context,
                                value: formatter.stringForValue(
                                    val,
                                    entry: e,
                                    dataSetIndex: dataSetIndex,
                                    viewPortHandler: viewPortHandler),
                                xPos: x,
                                yPos: val >= 0.0
                                    ? (rect.origin.y + posOffset)
                                    : (rect.origin.y + rect.size.height + negOffset),
                                font: valueFont,
                                align: .center,
                                color: dataSet.valueTextColorAt(j))
                        }
                        
                        if let icon = e.icon, dataSet.isDrawIconsEnabled
                        {
                            var px = x
                            var py = val >= 0.0
                                ? (rect.origin.y + posOffset)
                                : (rect.origin.y + rect.size.height + negOffset)
                            
                            px += iconsOffset.x
                            py += iconsOffset.y
                            
                            ChartUtils.drawImage(
                                context: context,
                                image: icon,
                                x: px,
                                y: py,
                                size: icon.size)
                        }
                    }
                }
                else
                {
                    // if we have stacks
                    
                    var bufferIndex = 0
                    
                    for index in 0 ..< Int(ceil(Double(dataSet.entryCount) * animator.phaseX))
                    {
                        guard let e = dataSet.entryForIndex(index) as? BarChartDataEntry else { continue }
                        
                        let vals = e.yValues
                        
                        let rect = buffer.rects[bufferIndex]
                        
                        let x = rect.origin.x + rect.size.width / 2.0
                        
                        // we still draw stacked bars, but there is one non-stacked in between
                        if vals == nil
                        {
                            if !viewPortHandler.isInBoundsRight(x)
                            {
                                break
                            }
                            
                            if !viewPortHandler.isInBoundsY(rect.origin.y)
                                || !viewPortHandler.isInBoundsLeft(x)
                            {
                                continue
                            }
                            
                            if dataSet.isDrawValuesEnabled
                            {
                                drawValue(
                                    context: context,
                                    value: formatter.stringForValue(
                                        e.y,
                                        entry: e,
                                        dataSetIndex: dataSetIndex,
                                        viewPortHandler: viewPortHandler),
                                    xPos: x,
                                    yPos: rect.origin.y +
                                        (e.y >= 0 ? posOffset : negOffset),
                                    font: valueFont,
                                    align: .center,
                                    color: dataSet.valueTextColorAt(index))
                            }
                            
                            if let icon = e.icon, dataSet.isDrawIconsEnabled
                            {
                                var px = x
                                var py = rect.origin.y +
                                    (e.y >= 0 ? posOffset : negOffset)
                                
                                px += iconsOffset.x
                                py += iconsOffset.y
                                
                                ChartUtils.drawImage(
                                    context: context,
                                    image: icon,
                                    x: px,
                                    y: py,
                                    size: icon.size)
                            }
                        }
                        else
                        {
                            // draw stack values
                            
                            let vals = vals!
                            var transformed = [CGPoint]()
                            
                            var posY = 0.0
                            var negY = -e.negativeSum
                            
                            for k in 0 ..< vals.count
                            {
                                let value = vals[k]
                                var y: Double
                                
                                if value == 0.0 && (posY == 0.0 || negY == 0.0)
                                {
                                    // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                                    y = value
                                }
                                else if value >= 0.0
                                {
                                    posY += value
                                    y = posY
                                }
                                else
                                {
                                    y = negY
                                    negY -= value
                                }
                                
                                transformed.append(CGPoint(x: 0.0, y: CGFloat(y * phaseY)))
                            }
                            
                            trans.pointValuesToPixel(&transformed)
                            
                            for k in 0 ..< transformed.count
                            {
                                let val = vals[k]
                                let drawBelow = (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0
                                let y = transformed[k].y + (drawBelow ? negOffset : posOffset)
                                
                                if !viewPortHandler.isInBoundsRight(x)
                                {
                                    break
                                }
                                
                                if !viewPortHandler.isInBoundsY(y) || !viewPortHandler.isInBoundsLeft(x)
                                {
                                    continue
                                }
                                
                                if dataSet.isDrawValuesEnabled
                                {
                                    drawValue(
                                        context: context,
                                        value: formatter.stringForValue(
                                            vals[k],
                                            entry: e,
                                            dataSetIndex: dataSetIndex,
                                            viewPortHandler: viewPortHandler),
                                        xPos: x,
                                        yPos: y,
                                        font: valueFont,
                                        align: .center,
                                        color: dataSet.valueTextColorAt(index))
                                }
                                
                                if let icon = e.icon, dataSet.isDrawIconsEnabled
                                {
                                    ChartUtils.drawImage(
                                        context: context,
                                        image: icon,
                                        x: x + iconsOffset.x,
                                        y: y + iconsOffset.y,
                                        size: icon.size)
                                }
                            }
                        }
                        
                        bufferIndex = vals == nil ? (bufferIndex + 1) : (bufferIndex + vals!.count)
                    }
                }
            }
        }
    }
    public override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }

        context.saveGState()

        var barRect = CGRect()

        for high in indices
        {

            guard
                let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet,
                set.isHighlightEnabled
                else { continue }

            if let e = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry
            {
                if !isInBoundsX(entry: e, dataSet: set)
                {
                    continue
                }

                let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
                context.setLineWidth(set.highlightLineWidth)
                context.setFillColor(set.highlightColor.cgColor)
                context.setAlpha(set.highlightAlpha)

                let isStack = high.stackIndex >= 0 && e.isStacked

                let y1: Double
                let y2: Double

                if isStack
                {
                    if dataProvider.isHighlightFullBarEnabled
                    {
                        y1 = e.positiveSum
                        y2 = -e.negativeSum
                    }
                    else
                    {
                        let range = e.ranges?[high.stackIndex]

                        y1 = range?.from ?? 0.0
                        y2 = range?.to ?? 0.0
                    }
                }
                else
                {
                    y1 = e.y
                    y2 = 0.0
                }
                prepareBarHighlight(x: e.x, y1: y1+(100-y1)+3, y2: y2-3, barWidthHalf: barData.barWidth / 1.25, trans: trans, rect: &barRect)

                setHighlightDrawPos(highlight: high, barRect: barRect)
                context.setStrokeColor(set.highlightColor.cgColor)

                let bezierPath = NSBezierPath(roundedRect: barRect, xRadius: 5, yRadius: 5)
                    //UIBezierPath(roundedRect: barRect, cornerRadius: 5)
                //context.addPath(bezierPath.cgPath)
                bezierPath.fill()
                context.drawPath(using: .stroke)
            }
        }
        context.restoreGState()

    }
   
    
}

public struct Corners: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Corners.RawValue) {
        self.rawValue = rawValue
    }
    
    public static let topLeft = Corners(rawValue: 1 << 0)
    public static let bottomLeft = Corners(rawValue: 1 << 1)
    public static let topRight = Corners(rawValue: 1 << 2)
    public static let bottomRight = Corners(rawValue: 1 << 3)
    
    public func flipped() -> Corners {
        var flippedCorners: Corners = []
        
        if contains(.bottomRight) {
            flippedCorners.insert(.topRight)
        }
        
        if contains(.topRight) {
            flippedCorners.insert(.bottomRight)
        }
        
        if contains(.bottomLeft) {
            flippedCorners.insert(.topLeft)
        }
        
        if contains(.topLeft) {
            flippedCorners.insert(.bottomLeft)
        }
        
        return flippedCorners
    }
}


public extension NSBezierPath {
    
    // Compatibility bewteen NSBezierPath and UIBezierPath
    #if os(iOS) || os(tvOS)
    public func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    public func line(to point: CGPoint) {
        addLine(to: point)
    }
    #endif
    
    public convenience init(rect: CGRect, roundedCorners: Corners, cornerRadius: CGFloat) {
        self.init()
        
        // On iOS & tvOS, we need to flip the corners
        #if os(iOS) || os(tvOS)
        let corners = roundedCorners.flipped()
        #elseif os(macOS)
        let corners = roundedCorners
        #endif
        
        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat =  0
        
        let bottomRightCorner = CGPoint(x: maxX, y: minY)
        
        
        if corners.contains(.bottomRight) {
            line(to: CGPoint(x: maxX - cornerRadius, y: minY))
            curve(to: CGPoint(x: maxX, y: minY + cornerRadius), controlPoint1: bottomRightCorner, controlPoint2: bottomRightCorner)
        }
        else {
            line(to: bottomRightCorner)
        }
        
        let topRightCorner = CGPoint(x: maxX, y: maxY)
        
        if corners.contains(.topRight) {
            line(to: CGPoint(x: maxX, y: maxY - cornerRadius))
            curve(to: CGPoint(x: maxX - cornerRadius, y: maxY), controlPoint1: topRightCorner, controlPoint2: topRightCorner)
        }
        else {
            line(to: topRightCorner)
        }
        
        let topLeftCorner = CGPoint(x: minX, y: maxY)
        
        if corners.contains(.topLeft) {
            line(to: CGPoint(x: minX + cornerRadius, y: maxY))
            curve(to: CGPoint(x: minX, y: maxY - cornerRadius), controlPoint1: topLeftCorner, controlPoint2: topLeftCorner)
        }
        else {
            line(to: topLeftCorner)
        }
        
        let bottomLeftCorner = CGPoint(x: minX, y: minY)
        
        if corners.contains(.bottomLeft) {
            line(to: CGPoint(x: minX, y: minY + cornerRadius))
            curve(to: CGPoint(x: minX + cornerRadius, y: minY), controlPoint1: bottomLeftCorner, controlPoint2: bottomLeftCorner)
        }
        else {
            line(to: bottomLeftCorner)
        }
    }
}