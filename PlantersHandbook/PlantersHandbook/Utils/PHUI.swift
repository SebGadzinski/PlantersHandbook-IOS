//
//  PHUI.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-03-08.
//

import Foundation
import UIKit

/// PHUI - Planters Handbook User Inteface - Customized views from UIKit and SUI specifically made for Planters Handbook Application
class PHUI{
    ///Creates a programic UITextField
    ///- Returns: Customized UITextField
    static func TextField_BagUp() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemBackground
        textField.textColor = .label
        textField.borderStyle = .none
        textField.backgroundColor = .systemBackground
        textField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.medium))
        textField.layer.masksToBounds = true
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
        textField.clipsToBounds = true
        return textField
    }
    ///Creates a programic UIButton
    ///- Parameter title: text in button
    ///- Parameter fontSize: font size for the text in the button
    ///- Returns: Customized UIButton
    static func button(title: String, fontSize: Float) -> UIButton{
        return SUI.buttonRounded(title: title, textColor: UIColor.systemGray, backgroundColor: UIColor.clear, fontSize: fontSize, borderColor: UIColor.systemGreen.cgColor, radius: CornerRaduis.small, borderWidth: BorderWidth.extraThin)
    }

    ///Creates a programic UIButton to be used in the TallyViewController
    ///- Parameter title: Text in button
    ///- Parameter fontSize: Font size for the text in the button
    ///- Parameter borderColor: Border color of button
    ///- Returns: Customized UIButton
    static func buttonTally(title: String, fontSize: Float, borderColor: CGColor) -> UIButton{
        let button = SUI.buttonRounded(title: title, textColor: UIColor.systemGray, backgroundColor: UIColor.clear, fontSize: fontSize, borderColor: borderColor, radius: CornerRaduis.medium, borderWidth: BorderWidth.extraThin)
        button.contentEdgeInsets = .init(top: 5, left: 10, bottom: 5, right: 10)
        return button
    }
    
    ///Creates a programic UILabel that should only contain a number
    ///- Parameter title: Text in UILabel
    ///- Returns: Customized UILabel
    static func labelNumber(title: String?) -> UILabel {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.adjustsFontSizeToFitWidth = true
        lb.text = (title != nil ? title :"")
        lb.textAlignment = .center
        lb.textColor = .label
        lb.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
        return lb
    }

    ///Creates a programic UILabel that is used in StatisticsViewController
    ///- Parameter title: Text in UILabel
    ///- Returns: Customized UILabel
    static func labelStat(title: String?) -> UILabel{
        let lb = SUI.label(title: title, fontSize: FontSize.small)
        let font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.small))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.label,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        if let newTitle = title{
            let lbString = NSAttributedString(string: newTitle,
                                                      attributes: attributes)
            lb.attributedText = lbString
        }
        return lb
    }
    
    ///Creates a programic UICollectionView for the TallyViewController
    ///- Returns: Customized UICollectionView
    static func collectionViewTally() -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TallyCell.self, forCellWithReuseIdentifier: "TallyCell")
        return cv
    }

    ///Creates a programic UICollectionView for the PrintHandbookEntryModalViewController
    ///- Returns: Customized UICollectionView
    static func collectionViewPrintableCache() -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(PrintedTallyCell.self, forCellWithReuseIdentifier: "PrintedTallyCell")
        return cv
    }

    ///Creates a programic UICollectionView for the PlotsModalViewController
    ///- Returns: Customized UICollectionView
    static func collectionViewPlots() -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(PlotCell.self, forCellWithReuseIdentifier: "PlotCell")
        return cv
    }

    ///Creates a programic UICollectionView for the StatisticsViewController
    ///- Returns: Customized UICollectionView
    static func collectionViewStatistics() -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        cv.backgroundColor = .systemBackground
        cv.dragInteractionEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cv.register(TotalCashCell.self, forCellWithReuseIdentifier: "TotalCashCell")
        cv.register(LineGraphCell.self, forCellWithReuseIdentifier: "LineGraphCell")
        cv.register(OverallStatsCell.self, forCellWithReuseIdentifier: "OverallStatsCell")
        cv.register(PieChartCell.self, forCellWithReuseIdentifier: "PieChartCell")
        cv.register(HorizontalBarGraphCell.self, forCellWithReuseIdentifier: "HorizontalBarGraphCell")
        cv.register(OneTotalCell.self, forCellWithReuseIdentifier: "OneTotalCell")
        return cv
    }

}
