//
//  CoordinateField.swift
//  MAGE
//
//  Created by Daniel Barela on 1/11/22.
//  Copyright © 2022 National Geospatial Intelligence Agency. All rights reserved.
//

import Foundation
import MaterialComponents
import UIKit
import CoreLocation

@objc protocol CoordinateFieldListener {
    @objc func fieldValueChanged(coordinate: CLLocationDegrees, field: CoordinateField);
}

@objc class CoordinateField:UIView {
    
    lazy var textField: MDCFilledTextField = {
        // this is just an estimated size
        let textField = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 100));
        textField.delegate = self
        textField.trailingView = UIImageView(image: UIImage(named: "outline_place"));
        textField.trailingViewMode = .always;
        textField.sizeToFit()
        return textField;
    }()
    
    @objc public var enabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
        }
    }
    
    @objc public var isEditing: Bool {
        get {
            return textField.isEditing
        }
    }
    
    @objc public var text: String? {
        get {
            return textField.text
        }
        set {
            parseAndUpdateText(newText: newValue)
        }
    }
    
    @objc public var label: String? {
        get {
            return textField.label.text
        }
        set {
            textField.label.text = newValue
        }
    }
    
    @objc public var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }
    
    @objc public var coordinate : CLLocationDegrees = CLLocationDegrees.nan
    var scheme : MDCContainerScheming?
    var latitude : Bool = true
    var delegate: CoordinateFieldListener?
    @objc public var linkedLongitudeField : CoordinateField?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    @objc public init(latitude: Bool = true, text: String? = nil, label: String? = nil, delegate: CoordinateFieldListener? = nil, scheme: MDCContainerScheming? = nil) {
        super.init(frame: CGRect.zero);
        self.scheme = scheme
        self.label = label
        self.latitude = latitude
        self.addSubview(textField)
        textField.autoPinEdgesToSuperviewEdges()
        self.text = text
        self.delegate = delegate
    }
    
    @objc func applyTheme(withScheme scheme: MDCContainerScheming?) {
        guard let scheme = scheme else {
            return
        }

        self.scheme = scheme
        textField.applyTheme(withScheme: scheme)
        textField.setFilledBackgroundColor(scheme.colorScheme.surfaceColor.withAlphaComponent(0.87), for: .normal)
        textField.setFilledBackgroundColor(scheme.colorScheme.surfaceColor.withAlphaComponent(0.87), for: .editing)
    }
    
    @objc func applyErrorTheme() {
        let scheme = globalErrorContainerScheme()
        textField.applyTheme(withScheme: scheme)
        textField.setFilledBackgroundColor(scheme.colorScheme.surfaceColor.withAlphaComponent(0.87), for: .normal)
        textField.setFilledBackgroundColor(scheme.colorScheme.surfaceColor.withAlphaComponent(0.87), for: .editing)
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return textField.resignFirstResponder()
    }

}

extension CoordinateField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // allow backspace, decimal point and dash at the begining of the string
        let text = textField.text?.replacingCharacters(in: Range(range, in: textField.text!)!, with: string).uppercased()

        if string.isEmpty || "." == string || ("-" == string && range.length == 0 && range.location == 0) {
            applyFieldTheme(text: text)
            return true
        }
        
        return parseAndUpdateText(newText: text, split: string.count > 1, addDirection: string.count > 1)
    }
    
    func applyFieldTheme(text: String?) {
        if text == nil || text!.isEmpty {
            applyTheme(withScheme: self.scheme)
            return
        }
        
        let parsedDMS: String? = LocationUtilities.parseToDMSString(text)
        
        let parsed = CLLocationCoordinate2D.parse(coordinate: text, enforceLatitude: latitude)
        
        if let parsed = parsed, let parsedDMS = parsedDMS {
            if LocationUtilities.validateCoordinateFromDMS(coordinate: parsedDMS, latitude: latitude) {
                applyTheme(withScheme: self.scheme)
                coordinate = parsed
                if let delegate = delegate {
                    delegate.fieldValueChanged(coordinate: coordinate, field:self)
                }
            } else {
                applyErrorTheme()
                if let delegate = delegate {
                    delegate.fieldValueChanged(coordinate: CLLocationDegrees.nan, field:self)
                }
            }
        } else {
            applyErrorTheme()
            if let delegate = delegate {
                delegate.fieldValueChanged(coordinate: CLLocationDegrees.nan, field:self)
            }
        }
    }
    
    @discardableResult
    func parseAndUpdateText(newText: String?, split: Bool = false, addDirection: Bool = false) -> Bool {
        var text = newText
        
        if split {
            let splitCoordinates = CLLocationCoordinate2D.splitCoordinates(coordinates: newText)
            
            if splitCoordinates.count == 2 {
                if latitude {
                    text = splitCoordinates[0]
                    if let linkedLongitudeField = linkedLongitudeField {
                        linkedLongitudeField.text = splitCoordinates[1]
                    }
                } else {
                    text = splitCoordinates[1]
                }
            } else if splitCoordinates.count == 1 {
                text = splitCoordinates[0]
            }

        }
        
        var parsedDMS: String? = nil
        var oldParsedDMS: String? = nil
        let oldText = textField.text
        
        parsedDMS = LocationUtilities.parseToDMSString(text, addDirection: addDirection, latitude: latitude)
        oldParsedDMS = LocationUtilities.parseToDMSString(oldText, addDirection: addDirection, latitude: latitude)
        
        applyFieldTheme(text: text)
        
        if let parsedDMS = parsedDMS, let oldParsedDMS = oldParsedDMS {

            var newCursorPosition = 0
            
            var charactersToKeep = CharacterSet()
            charactersToKeep.formUnion(.decimalDigits)
            
            // look for the first new character which is not a space or special DMS character and put the index there
            let trimmedParsedDMS = parsedDMS.components(separatedBy: charactersToKeep.inverted).joined()
            let trimmedOldParsedDMS = oldParsedDMS.components(separatedBy: charactersToKeep.inverted).joined()
            
            let newCharacterPosition = trimmedOldParsedDMS.commonPrefix(with: trimmedParsedDMS).count + 1
            var checkedCharacters = 0
            for (_, char) in parsedDMS.enumerated() {
                newCursorPosition += 1
                if "\(char)".rangeOfCharacter(from: charactersToKeep) != nil {
                    checkedCharacters += 1
                    if checkedCharacters == newCharacterPosition {
                        break
                    }
                }
            }
            
            textField.text = parsedDMS

            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorPosition) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return false
        } else {
            let arbitraryValue: Int = 1
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: arbitraryValue) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
        
        return true
    }
}
