//
//  PieChartCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

///PieChartCell.swift - Graph card cell with a pie chart
class PieChartCell: GraphCardCell {
    
    var pieChart = SUI.pieChart()
    
    ///Constructor that sets up the frame of the cell
    ///- Parameter frame: Frame of cell (x and y locations on screen and size)
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Creates  layout for cell
    override func generateLayout(){
        super.generateLayout()
        graphView.addSubview(pieChart)
        pieChart.noDataText = "You need to create a season and add a entry"
        pieChart.anchor(top: graphView.topAnchor, leading: graphView.leadingAnchor, bottom: graphView.bottomAnchor, trailing: graphView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 5, right: 5))
    }

}
