//
//  HorizontalBarGraphCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

///HorizontalBarGraphCell.swift - Graph card cell with a horizonatal bar chart
class HorizontalBarGraphCell: GraphCardCell {
    
    let barChart = SUI.hortiontalBarGraph()
    
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
        graphView.addSubview(barChart)
        barChart.noDataText = "You need to create a season and add a entry"
        barChart.anchor(top: graphView.topAnchor, leading: graphView.leadingAnchor, bottom: graphView.bottomAnchor, trailing: graphView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 20, right: 5))
    }

}
