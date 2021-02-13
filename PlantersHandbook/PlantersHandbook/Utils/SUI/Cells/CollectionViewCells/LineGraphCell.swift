//
//  LineGraphCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit
import Charts

class LineGraphCell: GraphCardCell {

    var lineChart = SUI_LineGraph()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        graphView.addSubview(lineChart)
        lineChart.noDataText = "You must have 5 Entries in a season to see this graph"
        lineChart.anchor(top: graphView.topAnchor, leading: graphView.leadingAnchor, bottom: graphView.bottomAnchor, trailing: graphView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 5, right: 5))
    }
}
