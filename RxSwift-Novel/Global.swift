
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

func lineSpaceStr(attr: NSMutableAttributedString, font: UIFont, space: CGFloat) -> NSMutableAttributedString {
    let paraph = NSMutableParagraphStyle()
    paraph.lineSpacing = space
    paraph.alignment = .justified
    let attributes = [NSAttributedString.Key.font: font,
                      NSAttributedString.Key.paragraphStyle: paraph]
    attr.addAttributes(attributes, range: NSRange(location: 0, length: attr.length))
    return attr
}
