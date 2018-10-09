import XCTest
import FBSnapshotTestCase
@testable import Charts

class BarChartTests: FBSnapshotTestCase
{
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = true
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: Prepare
    func createCustomValuesDataEntries(values: [Double]) -> [ChartDataEntry]
    {
        var entries: [ChartDataEntry] = Array()
        for (i, value) in values.enumerated()
        {
            entries.append(BarChartDataEntry(x: Double(i), y: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        return entries
    }
    func createDefaultValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [8, 104, -81, 93, 52, -44, 97, 101, -75, 28,
                                -76, 25, 20, -13, 52, 44, -57, 23, 45, -91,
                                99, 14, -84, 48, 40, -71, 106, 41, -45, 61]
        return createCustomValuesDataEntries(values: values)
    }
    func createPositiveValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [8, 104, 81, 93, 52, 44, 97, 101, 75, 28,
                                76, 25, 20, 13, 52, 44, 57, 23, 45, 91,
                                99, 14, 84, 48, 40, 71, 106, 41, 45, 61]
        return createCustomValuesDataEntries(values: values)
    }
    func createNegativeValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [-8, -104, -81, -93, -52, -44, -97, -101, -75, -28,
                                -76, -25, -20, -13, -52, -44, -57, -23, -45, -91,
                                -99, -14, -84, -48, -40, -71, -106, -41, -45, -61]
        return createCustomValuesDataEntries(values: values)
    }
    func createZeroValuesDataEntries() -> [ChartDataEntry]
    {
        let values: [Double] = [0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0]
        return createCustomValuesDataEntries(values: values)
    }
    func createDefaultDataSet(chartDataEntries: [ChartDataEntry]) -> BarChartDataSet
    {
        let dataSet = BarChartDataSet(values: chartDataEntries, label: "Bar chart unit test data")
        dataSet.drawIconsEnabled = false
        dataSet.iconsOffset = CGPoint(x: 0, y: -10.0)
        return dataSet
    }
    func createDefaultChart(dataSets: [BarChartDataSet]) -> BarChartView
    {
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = 0.85
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: 480, height: 350))
        chart.backgroundColor = NSUIColor.clear
        chart.data = data
        return chart
    }
    
    //MARK: Start Test
    func testDefaultValues()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testZeroValues()
    {
        let dataEntries = createZeroValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testPositiveValues()
    {
        let dataEntries = createPositiveValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testPositiveValuesWithCustomAxisMaximum()
    {
        let dataEntries = createPositiveValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 50
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testPositiveValuesWithCustomAxisMinimum()
    {
        let dataEntries = createPositiveValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = 50
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testPositiveValuesWithCustomAxisMaximumAndCustomAxisMaximum()
    {
        let dataEntries = createPositiveValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        //If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = -10
        chart.leftAxis.axisMinimum = 200
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testNegativeValues()
    {
        let dataEntries = createNegativeValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testNegativeValuesWithCustomAxisMaximum()
    {
        let dataEntries = createNegativeValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMaximum = 10
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testNegativeValuesWithCustomAxisMinimum()
    {
        let dataEntries = createNegativeValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.axisMinimum = -200
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testNegativeValuesWithCustomAxisMaximumAndCustomAxisMaximum()
    {
        let dataEntries = createNegativeValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        //If min is greater than max, then min and max will be exchanged.
        chart.leftAxis.axisMaximum = -200
        chart.leftAxis.axisMinimum = 10
        chart.notifyDataSetChanged()
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    func testHidesValues()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        dataSet.drawValuesEnabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideLeftAxis()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.enabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideRightAxis()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.rightAxis.enabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideHorizontalGridlines()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.leftAxis.drawGridLinesEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testHideVerticalGridlines()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        chart.xAxis.drawGridLinesEnabled = false
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
    
    func testDrawIcons()
    {
        let dataEntries = createDefaultValuesDataEntries()
        let dataSet = createDefaultDataSet(chartDataEntries: dataEntries)
        let chart = createDefaultChart(dataSets: [dataSet])
        dataSet.drawIconsEnabled = true
        FBSnapshotVerifyView(chart, identifier: Snapshot.identifier(UIScreen.main.bounds.size), tolerance: Snapshot.tolerance)
    }
}
