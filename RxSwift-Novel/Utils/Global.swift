
//
//  Global.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/6.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

let SCREEN_SIZE = UIScreen.main.bounds.size
let SCREEN_WIDTH = SCREEN_SIZE.width
let SCREEN_HEIGHT = SCREEN_SIZE.height

func Dlog(_ item : Any, file : String = #file, lineNum : Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("\n--- fileName:\(fileName) lineNum:\(lineNum) --- \n \(item) \n")
    #endif
}

func RGBColor(_ rgbValue: UInt) -> UIColor {
    return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0, blue: CGFloat(rgbValue & 0x0000FF)/255.0, alpha: 1.0)
}

func lineSpaceStr(attr: NSMutableAttributedString, font: UIFont, space: CGFloat) -> NSMutableAttributedString {
    let paraph = NSMutableParagraphStyle()
    paraph.lineSpacing = space
    paraph.alignment = .justified
    let attributes = [NSAttributedString.Key.font: font,
                      NSAttributedString.Key.paragraphStyle: paraph]
    attr.addAttributes(attributes, range: NSRange(location: 0, length: attr.length))
    return attr
}
