//
//  ResultController.swift
//  MusicTest
//
//  Created by Vladimir Gnatiuk on 1/11/16.
//  Copyright © 2016 Vladimir Gnatiuk. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class ResultController: UIViewController, ChartViewDelegate {
    var userName: String?
    var selectedInstrument: Instruments?
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var chartView: HorizontalBarChartView!
    @IBOutlet weak var legendChartView: HorizontalBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        chartView.delegate = self
        chartView.descriptionText = ""
        chartView.noDataTextDescription = ""
        chartView.noDataText = ""
        chartView.drawBarShadowEnabled = false
        chartView.maxVisibleValueCount = 60
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.legend.enabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        xAxis.labelFont = UIFont.systemFontOfSize(12)
        xAxis.labelTextColor = UIColor.whiteColor()
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.valueFormatter = ChartCustomXAxisValueFormatter()
        
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false

        legendChartView.leftAxis.drawGridLinesEnabled = false
        legendChartView.rightAxis.drawGridLinesEnabled = false
        legendChartView.leftAxis.drawAxisLineEnabled = false
        legendChartView.rightAxis.drawAxisLineEnabled = false
        legendChartView.xAxis.drawGridLinesEnabled = false
        legendChartView.xAxis.drawAxisLineEnabled = false
        legendChartView.legend.enabled = false
        legendChartView.drawGridBackgroundEnabled = false
        legendChartView.drawBarShadowEnabled = false
        legendChartView.descriptionTextColor = UIColor.clearColor()
        legendChartView.descriptionText = ""
        legendChartView.noDataTextDescription = ""
        legendChartView.noDataText = ""
        
        let xLegendAxis = legendChartView.xAxis
        xLegendAxis.labelPosition = ChartXAxis.XAxisLabelPosition.BottomInside
        xLegendAxis.labelFont = UIFont.systemFontOfSize(12)
        xLegendAxis.labelTextColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        RestAPI.sharedInstance.pollResults({ (json) -> () in
            self.setupDataSource(json)
            self.setupLabel(json)
            }) { (error) -> () in
                print(error)
        }
    }
    
    func setupDataSource(json: JSON) {
        let instruments = [Instruments.Guitar, Instruments.ElectricGuitar, Instruments.Bass, Instruments.Banjo].reverse()
        var xVals = [String]()
        let xLegendsVals = instruments.map({ $0.description() })

        var yVals = [BarChartDataEntry]()
        var yLegendVals = [BarChartDataEntry]()
        for (index, instrument) in instruments.enumerate() {
            if let value = instrument.jsonValue(json) {
                yVals.append(BarChartDataEntry(value: value, xIndex: index))
                yLegendVals.append(BarChartDataEntry(value: 1, xIndex: index))
                xVals.append(String(value))
            }
        }
        let dataSet = BarChartDataSet(yVals: yVals, label: "DataSet")
        dataSet.barSpace = 0.35
        dataSet.colors = instruments.map({ $0.color() })
        dataSet.stackLabels = instruments.map({ $0.description() })
        let data = BarChartData(xVals: xVals, dataSet: dataSet)
        
        chartView.data = data
        chartView.animate(yAxisDuration:2.5)
        
        let legendDataSet = BarChartDataSet(yVals: yLegendVals, label: "LegendDataSet")
        legendDataSet.barSpace = 0.35
        legendDataSet.visible = false
        let legendData = BarChartData(xVals: xLegendsVals, dataSet: legendDataSet)
        legendChartView.data = legendData
    }
    
    func setupLabel(json: JSON) {
        if let userName = userName, let selectedIntrumentValue = selectedInstrument?.jsonValue(json) {
            resultLabel.text = "\(userName), \(selectedIntrumentValue)% also like \(selectedInstrument!.description())!"
        }
    }

}

/// An interface for providing custom x-axis Strings.
public class ChartCustomXAxisValueFormatter: NSObject, ChartXAxisValueFormatter
{
    public func stringForXValue(index: Int, original: String, viewPortHandler: ChartViewPortHandler) -> String
    {
        return "\(original)%" // just return original, no adjustments
    }
    
}
