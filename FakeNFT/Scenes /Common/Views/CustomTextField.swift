//
//  CustomUITextField.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 26.02.2024.
//

import UIKit

final class CustomTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 41.0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }
}
