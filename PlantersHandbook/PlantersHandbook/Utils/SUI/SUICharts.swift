//
//  SUICharts.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-04.
//

import Foundation
import Charts

func SUI_LineGraph() -> LineChartView{
    let lineGraph = LineChartView()
    lineGraph.setVisibleXRangeMaximum(ChartNumbers.visibleRandMaximum)
    lineGraph.xAxis.granularity = 1
    lineGraph.xAxis.axisMinimum = 0.0
    lineGraph.xAxis.labelPosition = .bottom
//    dayLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
//    lineGraph.xAxis.labelCount = cashDataSet.count
//    lineGraph.moveViewToX(Double(entryManager.count))
//    dayLineChart.data = .none
//    dayLineChart.noDataText = "No data"
    lineGraph.xAxis.labelRotationAngle = -90.0
    lineGraph.xAxis.drawGridLinesEnabled = false
    lineGraph.xAxis.drawAxisLineEnabled = true
    
    lineGraph.leftAxis.enabled = false
    lineGraph.leftAxis.drawGridLinesEnabled = false
    lineGraph.leftAxis.drawAxisLineEnabled = false
    
    lineGraph.rightAxis.axisMinimum = 0.0
    lineGraph.rightAxis.enabled = false
    lineGraph.rightAxis.drawAxisLineEnabled = false
    lineGraph.rightAxis.drawGridLinesEnabled = false
    
    lineGraph.setDragOffsetX(20)
    lineGraph.accessibilityScroll(.right)
    return lineGraph
}

func SUI_PieChart() -> PieChartView{
    let pieChart = PieChartView()
    //makeStuffNice
    return pieChart
}

func SUI_HortiontalBarGraph() -> BarChartView{
    let barGraph = BarChartView()
    barGraph.isUserInteractionEnabled = false
                
    barGraph.leftAxis.axisMinimum = 0.0
    barGraph.xAxis.labelPosition = .bottom
//    barGraph.xAxis.labelCount = cashDataSet.count

    barGraph.rightAxis.enabled = false

    barGraph.xAxis.drawGridLinesEnabled = false
    barGraph.xAxis.drawAxisLineEnabled = false

    barGraph.rightAxis.drawAxisLineEnabled = true
    barGraph.rightAxis.drawGridLinesEnabled = false

    barGraph.leftAxis.drawGridLinesEnabled = false
    barGraph.leftAxis.drawAxisLineEnabled = false
    return barGraph
}

