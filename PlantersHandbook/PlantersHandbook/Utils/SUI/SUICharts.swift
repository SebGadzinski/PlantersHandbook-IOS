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
    lineGraph.setVisibleXRangeMaximum(ChartNumbers.requiredInputValuesAmount)
    lineGraph.xAxis.granularity = 1
    lineGraph.xAxis.labelPosition = .bottom

    lineGraph.xAxis.labelRotationAngle = -90.0
    lineGraph.xAxis.drawGridLinesEnabled = false
    lineGraph.xAxis.drawAxisLineEnabled = true
    
    lineGraph.leftAxis.enabled = false
    lineGraph.leftAxis.drawGridLinesEnabled = false
    lineGraph.leftAxis.drawAxisLineEnabled = false
    
    lineGraph.rightAxis.axisMinimum = -1
    lineGraph.rightAxis.enabled = false
    lineGraph.rightAxis.drawAxisLineEnabled = false
    lineGraph.rightAxis.drawGridLinesEnabled = false
    lineGraph.animate(xAxisDuration: 1, easingOption: .easeInElastic)
    
    lineGraph.setDragOffsetX(20)
    lineGraph.accessibilityScroll(.right)
    return lineGraph
}

func SUI_PieChart() -> PieChartView{
    let pieChart = PieChartView()
    //makeStuffNice
    pieChart.animate(yAxisDuration: 1.5, easingOption: .easeInQuart)
    return pieChart
}

func SUI_HortiontalBarGraph() -> HorizontalBarChartView{
    let barChart = HorizontalBarChartView()
    
    barChart.chartDescription?.text = ""
    barChart.pinchZoomEnabled = false
    barChart.doubleTapToZoomEnabled = false
    
    barChart.leftAxis.axisMinimum = 0.0
    barChart.xAxis.labelPosition = .bottom
    barChart.xAxis.drawGridLinesEnabled = false
    barChart.rightAxis.drawGridLinesEnabled = false
    
    barChart.leftAxis.enabled = false
    barChart.leftAxis.drawAxisLineEnabled = false
    barChart.leftAxis.drawLabelsEnabled = false
    barChart.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
    barChart.legend.enabled = false

    barChart.fitBars = true;
    return barChart
}

