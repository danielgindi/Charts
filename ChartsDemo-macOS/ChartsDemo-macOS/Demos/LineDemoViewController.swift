//
//  LineDemoViewController.swift
//  ChartsDemo-OSX
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts

import Charts
import Cocoa
import Foundation

open class LineDemoViewController: NSViewController {
    @IBOutlet var lineChartView: LineChartView!

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let ys1 = Array(1 ..< 10).map { x in sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = Array(1 ..< 10).map { x in cos(Double(x) / 2.0 / 3.141) }

        let yse1 = ys1.enumerated().map { x, y in ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in ChartDataEntry(x: Double(x), y: y) }

        let data = LineChartData()
        let ds1 = LineChartDataSet(entries: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.append(ds1)

        let ds2 = LineChartDataSet(entries: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.append(ds2)
        lineChartView.data = data

        lineChartView.gridBackgroundColor = NSUIColor.white

        lineChartView.chartDescription.text = "Linechart Demo"
    }

    override open func viewWillAppear() {
        lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
}
