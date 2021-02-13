//
//  HorizontalBarGraphCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class HorizontalBarGraphCell: GraphCardCell {
    
    let barChart = SUI_HortiontalBarGraph()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        graphView.addSubview(barChart)
        barChart.noDataText = "You need to create a season and add a entry"
        barChart.anchor(top: graphView.topAnchor, leading: graphView.leadingAnchor, bottom: graphView.bottomAnchor, trailing: graphView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 20, right: 5))
    }

}
