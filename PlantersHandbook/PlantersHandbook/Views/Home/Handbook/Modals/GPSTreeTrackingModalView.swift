//
//  GPSTreeTrackingModalView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit
import GoogleMaps

class GPSTreeTrackingModalView: ProgramicVC {
    internal var googleMapsLayout = SUI_View(backgoundColor: .systemBackground)
    internal var actionLayout = SUI_View(backgoundColor: .systemBackground)
    
    internal let engageTrackingButton = PH_Button(title: "Start Planting", fontSize: FontSize.large)
    internal let distanceTravelledTextField = SUI_Label(title: "0 m", fontSize: FontSize.extraLarge)
    internal let treesPlantedTheoreticallyTextField = SUI_Label(title: "0 trees", fontSize: FontSize.extraLarge)
    internal let treesPerPlotTextField = SUI_TextField_Form(placeholder: "Trees Per Plot", textType: .none)
    internal let undoImage = UIImageView(image: UIImage(named: "undoBtn.png"))
    internal let timerView = SUI_TextView_RoundedBackground(text: "00:00:00", fontSize: FontSize.large)
    internal var mapView = GMSMapView()
    
    override func setUpOverlay() {
        super.setUpOverlay()
        let frame = backgroundView.safeAreaFrame
        
        let blackBar = UIView()
        blackBar.backgroundColor = .secondaryLabel
        
        [googleMapsLayout, blackBar, actionLayout].forEach{backgroundView.addSubview($0)}

        googleMapsLayout.anchor(top: backgroundView.topAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor,size: .init(width: 0, height: frame.height*0.70))
        blackBar.anchor(top: googleMapsLayout.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: 3))
        actionLayout.anchor(top: blackBar.bottomAnchor, leading: backgroundView.leadingAnchor, bottom: nil, trailing: backgroundView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
    }

    override func configureViews() {
        super.configureViews()
        setUpGoogleMapsLayout()
        setUpActionLayout()
    }


    private func setUpGoogleMapsLayout(){
        mapView.mapType = .satellite
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        
        //Bar for people to grab and close the modal
        let topBar = SUI_View(backgoundColor: .clear)
        
        [mapView, topBar].forEach{googleMapsLayout.addSubview($0)}
    
        topBar.anchor(top: googleMapsLayout.topAnchor, leading: googleMapsLayout.leadingAnchor, bottom: nil, trailing: googleMapsLayout.trailingAnchor, size: .init(width: 0, height: googleMapsLayout.safeAreaFrame.height*0.2))
        
        mapView.anchor(top: googleMapsLayout.topAnchor, leading: googleMapsLayout.leadingAnchor, bottom: googleMapsLayout.bottomAnchor, trailing: googleMapsLayout.trailingAnchor)
        
        [undoImage, timerView].forEach{topBar.addSubview($0)}
        
        undoImage.anchor(top: topBar.topAnchor, leading: nil, bottom: nil, trailing: topBar.trailingAnchor,  padding: .init(top: 5, left: 0, bottom: 0, right: 5) ,size: .init(width: mapView.safeAreaFrame.width*0.13, height: mapView.safeAreaFrame.width*0.13))
        timerView.anchor(top: topBar.topAnchor, leading: topBar.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 8, left: 5, bottom: 0, right: 0), size: .init(width: mapView.safeAreaFrame.width*0.35, height: mapView.safeAreaFrame.width*0.12))
        undoImage.isUserInteractionEnabled = true
    }
    
    private func setUpActionLayout(){
        [engageTrackingButton, treesPerPlotTextField, distanceTravelledTextField, treesPlantedTheoreticallyTextField].forEach{actionLayout.addSubview($0)}

        engageTrackingButton.anchor(top: actionLayout.topAnchor, leading: actionLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 10), size: .init(width: actionLayout.safeAreaFrame.width/2, height: actionLayout.safeAreaFrame.height*0.45))
        
        treesPerPlotTextField.anchor(top: engageTrackingButton.bottomAnchor, leading: engageTrackingButton.leadingAnchor, bottom: nil, trailing: engageTrackingButton.trailingAnchor, padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        treesPerPlotTextField.textAlignment = .center
        treesPerPlotTextField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.medium))
        
        treesPerPlotTextField.keyboardType = .numberPad

        distanceTravelledTextField.anchor(top: nil, leading: engageTrackingButton.trailingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, size: .init(width: 0, height: actionLayout.safeAreaFrame.height*0.45))
        distanceTravelledTextField.anchorCenterY(to: engageTrackingButton)

        treesPlantedTheoreticallyTextField.anchor(top: nil, leading: treesPerPlotTextField.trailingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, size: .init(width: 0, height: actionLayout.safeAreaFrame.height*0.45))
        treesPlantedTheoreticallyTextField.anchorCenterY(to: treesPerPlotTextField)
        treesPlantedTheoreticallyTextField.anchorCenterX(to: distanceTravelledTextField)
        treesPlantedTheoreticallyTextField.textColor = .systemGreen
    }

}
