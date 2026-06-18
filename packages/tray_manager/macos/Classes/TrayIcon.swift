import SwiftUI
//
//  TrayIcon.swift
//  tray_manager
//
//  Created by Lijy91 on 2022/5/15.
//

public class TrayIcon: NSView {
    public var onTrayIconMouseDown:(() -> Void)?
    public var onTrayIconMouseUp:(() -> Void)?
    public var onTrayIconRightMouseDown:(() -> Void)?
    public var onTrayIconRightMouseUp:(() -> Void)?
    
    var statusItem: NSStatusItem?
    
    var textAttributes: [NSAttributedString.Key : Any]?
    
    private let imageView: NSImageView = {
        let iv = NSImageView()
        iv.imageScaling = .scaleProportionallyDown
        iv.isHidden = true
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()
    
    private let textField: NSTextField = {
        let field = NSTextField()
        field.isEditable = false
        field.isBezeled = false
        field.isHidden = true
        field.drawsBackground = false
        field.cell?.wraps = false
        field.alignment = .right
        return field
    }()
    
    private let stackView: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 6
        stack.distribution = .equalSpacing
        return stack
    }()
    
    
    public init() {
        super.init(frame: NSRect.zero)
        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 9
        paragraphStyle.minimumLineHeight = 9
        paragraphStyle.alignment = .right
        paragraphStyle.lineBreakMode = .byClipping
        
        textAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: NSFont.systemFont(ofSize: 8.75),
            .foregroundColor: NSColor.labelColor
        ]
        
        if let button = statusItem?.button {
            // ponytail: native status bar button avoids AppKit snapshotting a custom view.
            button.target = self
            button.action = #selector(statusItemButtonClicked(sender:))
            button.sendAction(on: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp])
            button.imagePosition = .imageLeading
        }
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor,constant:2),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant:-2),
        ])
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 42),
            textField.trailingAnchor.constraint(equalTo:stackView.trailingAnchor),
        ])
    }
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image: NSImage, _ imagePosition: String) {
        if let button = statusItem?.button {
            button.image = image
            button.imagePosition = .imageLeading
            button.sizeToFit()
        }
    }
    
    public func setImagePosition(_ imagePosition: String) {
        self.frame = statusItem!.button!.frame
    }
    
    public func removeImage() {
        statusItem?.button?.image = nil
    }
    
    public func setTitle(_ title: String) {
        if let button = statusItem?.button {
            button.attributedTitle = NSAttributedString(string: title, attributes: textAttributes)
            button.sizeToFit()
        }
    }
    
    public func setToolTip(_ toolTip: String) {
        if let button = statusItem?.button {
            button.toolTip  = toolTip
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        statusItem?.button?.highlight(true)
        self.onTrayIconMouseDown?()
    }
    
    public override func mouseUp(with event: NSEvent) {
        statusItem?.button?.highlight(false)
        self.onTrayIconMouseUp?()
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        self.onTrayIconRightMouseDown?()
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        self.onTrayIconRightMouseUp?()
    }

    @objc private func statusItemButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }
        switch event.type {
        case .leftMouseDown:
            onTrayIconMouseDown?()
        case .leftMouseUp:
            onTrayIconMouseUp?()
        case .rightMouseDown:
            onTrayIconRightMouseDown?()
        case .rightMouseUp:
            onTrayIconRightMouseUp?()
        default:
            break
        }
    }
}
