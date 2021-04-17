//
//  Charts.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-04.
//

import Foundation
import Charts

///Charts.swift - All custom made Charts given in static functions from SUI
extension SUI{
    ///Creates a line graph
    ///- Returns: Customized LineChartView
    static func lineGraph() -> LineChartView{
        let lineGraph = LineChartView()
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
        
//        lineGraph.setDragOffsetX(20)
        lineGraph.accessibilityScroll(.right)
        return lineGraph
    }

    ///Creates a  pie chart
    ///- Returns: Customized PieChartView
    static func pieChart() -> PieChartView{
        let pieChart = PieChartView()
        pieChart.animate(yAxisDuration: 1.5, easingOption: .easeInQuart)
        return pieChart
    }

    ///Creates a horizonatal bar graph
    ///- Returns: Customized HorizontalBarChartView
    static func hortiontalBarGraph() -> HorizontalBarChartView{
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

}
