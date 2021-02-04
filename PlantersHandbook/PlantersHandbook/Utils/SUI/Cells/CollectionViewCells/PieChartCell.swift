//
//  PieChartCell.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-31.
//

import UIKit

class PieChartCell: GraphCardCell {
    
    var pieChart = SUI_PieChart()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout(){
        super.generateLayout()
        graphView.addSubview(pieChart)
        pieChart.anchor(top: graphView.topAnchor, leading: graphView.leadingAnchor, bottom: graphView.bottomAnchor, trailing: graphView.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 5, right: 5))
    }

}
