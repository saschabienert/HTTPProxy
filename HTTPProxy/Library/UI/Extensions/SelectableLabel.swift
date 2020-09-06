//  https://medium.com/kinandcartacreated/making-uilabel-accessible-5f3d5c342df4
//
//  SelectableLabel.swift
//  SelectableLabel
//
//  Created by Sam Dods on 08/10/2019.
//  Copyright © 2019 Sam Dods. All rights reserved.
//

import UIKit

final class SelectableLabel: UILabel {
    
    // MARK: - Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextSelection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextSelection()
    }
    
    private func setupTextSelection() {
        layer.addSublayer(selectionOverlay)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        addGestureRecognizer(longPress)
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(didHideMenu), name: UIMenuController.didHideMenuNotification, object: nil)
    }
    
    private let selectionOverlay: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 8
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.14).cgColor
        layer.isHidden = true
        return layer
    }()
    
    // MARK: - Showing and hiding the menu
    
    private func cancelSelection() {
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    @objc private func didHideMenu(_ notification: Notification) {
        selectionOverlay.isHidden = true
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let text = text, !text.isEmpty else { return }
        becomeFirstResponder()
        
        let menu = menuForSelection()
        if !menu.isMenuVisible {
            selectionOverlay.isHidden = false
            menu.setTargetRect(textRect(), in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    private func textRect() -> CGRect {
        let inset: CGFloat = -4
        return textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).insetBy(dx: inset, dy: inset)
    }
    
    private func menuForSelection() -> UIMenuController {
        let menu = UIMenuController.shared
        menu.menuItems = [
            UIMenuItem(title: "Copy", action: #selector(copyText))
        ]
        return menu
    }
    
    // MARK: - Menu item actions
    
    @objc private func copyText(_ sender: Any?) {
        cancelSelection()
        let board = UIPasteboard.general
        board.string = text
    }
    
    // MARK: - UIView overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectionOverlay.frame = textRect()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        cancelSelection()
        return super.resignFirstResponder()
    }
}
