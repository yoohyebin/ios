//
//  RoundButton.swift
//  Calculator
//
//  Created by 유혜빈 on 2021/11/19.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable var isRound: Bool = false{   //storyboar에서 변경 가능
         didSet{
             if isRound{
                 self.layer.cornerRadius = self.frame.height / 2
             }
         }
    }
}
