//
//  CustomSegmentedControl.swift
//  FER
//
//  Created by Dmitry Reshetnik on 09.11.2020.
//

import UIKit

@IBDesignable public class CustomSegmentedControl: UIControl {
    fileprivate var labels: [UILabel] = []
    private var thumbView: UIView = UIView()
    
    public var items: [String] = ["Item 1", "Item 2"] {
        didSet {
            if items.count > 0 {
                setupLabels()
            }
        }
    }
    
    public var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    public var padding: CGFloat = 0.0 {
        didSet {
            setupLabels()
        }
    }
    
    @IBInspectable public var selectedLabelColor: UIColor = UIColor.black {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var unselectedLabelColor: UIColor = UIColor.white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var thumbColor: UIColor = UIColor.white {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var font: UIFont? = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            setFont()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if labels.count > 0 {
            let label = labels[selectedIndex]
            label.textColor = selectedLabelColor
            thumbView.frame = label.frame
            thumbView.backgroundColor = thumbColor
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
            displayNewSelectedIndex()
        }
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        layer.borderWidth = 2
        
        backgroundColor = UIColor.clear
        setupLabels()
        insertSubview(thumbView, at: 0)
    }
    
    private func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        for index in 1...items.count {
            let label = UILabel()
            label.text = items[index - 1]
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = font
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self)
    }
    
    private func displayNewSelectedIndex() {
        for (_, item) in labels.enumerated() {
            item.textColor = unselectedLabelColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            animations: {
                self.thumbView.frame = label.frame
            },
            completion: nil
        )
    }
    
    private func addIndividualItemConstraints(_ items: [UIView], mainView: UIView) {
        for (index, button) in items.enumerated() {
            button.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding).isActive = true
            button.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding).isActive = true
            
            // Set leading constraint
            if index == 0 {
                // Set first item leading anchor to mainView
                button.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding).isActive = true
            } else {
                let prevButton: UIView = items[index - 1]
                let firstItem: UIView = items[0]
                
                // Set remaining items to previous view and set width the same as first view
                button.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: padding).isActive = true
                button.widthAnchor.constraint(equalTo: firstItem.widthAnchor).isActive = true
            }
            
            // Set trailing constraint
            if index == items.count - 1 {
                // Set last item trailing anchor to mainView
                button.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding).isActive = true
            } else {
                // Set remaining item trailing anchor to next view
                let nextButton: UIView = items[index + 1]
                button.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -padding).isActive = true
            }
        }
    }
    
    private func setSelectedColors() {
        for item in labels {
            item.textColor = unselectedLabelColor
        }
        
        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }
        
        thumbView.backgroundColor = thumbColor
    }
    
    private func setFont() {
        for item in labels {
            item.font = font
        }
    }

}
