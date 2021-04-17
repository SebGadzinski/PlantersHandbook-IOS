//
//  UIViewExtensions.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import Foundation
import UIKit

///UIViewExtensions.swift - All custom made functions/attributes for UIView
extension UIView {

    ///Sets constraints to edges of super view
    func fillSuperView(){
        translatesAutoresizingMaskIntoConstraints = false
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    ///Sets constraints to edges of given view
    ///- Parameter view: Super view
    func fillSafeSuperView(to view: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }

    ///Sets width and height enchors to given views width and height anchors
    func anchorSize(to view: UIView){
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    ///Sets centerX&YAnchors equal to views centerX&YAnchors
    ///- Parameter view: UIView to be used
    func anchorCenter(to view: UIView){
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    ///Sets centerXAnchors equal to views centerXAnchors
    ///- Parameter view: UIView to be used
    func anchorCenterX(to view: UIView){
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    ///Sets centerYAnchors equal to views centerYAnchors
    ///- Parameter view: UIView to be used
    func anchorCenterY(to view: UIView){
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    ///Sets a given width and height to be the width and height contraints
    ///- Parameter width: Width constraint
    ///- Parameter height: Height constraint
    func anchorHeightAndWidthConstants(width: CGFloat, height: CGFloat){
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    ///Make the view underneath, and same length as given view
    ///- Parameter view: UIView to be used
    func anchorUnderline(to view: UIView){
        anchor(top: view.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
    }
    
    ///Sets width and height constraints based on size given
    ///- Parameter size: Desired size of view
    func anchorSize(size: CGSize = .zero){
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    ///Sets the padding of the view
    ///- Parameter padding: Desired padding for view
    func padding(padding: UIEdgeInsets = .zero){
            topAnchor.constraint(equalTo: topAnchor, constant: padding.top).isActive = true
            leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left).isActive = true
            bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom).isActive = true
            trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right).isActive = true
    }

    ///Sets the anchors, padding, and size of the view
    ///- Parameter top: Top anchor
    ///- Parameter leading: Leading anchor
    ///- Parameter bottom: Bottom anchor
    ///- Parameter trailing: Trailing anchor
    ///- Parameter padding: Desired padding for view
    ///- Parameter size: Desired size of view
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    ///Gives safe area frame if IOS is over 11
    public var safeAreaFrame: CGRect {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.layoutFrame
        }
        return bounds
    }
    
}

