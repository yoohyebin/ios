//
//  DiaryCell.swift
//  Diary
//
//  Created by 유혜빈 on 2021/11/24.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //UIView 생성시 이 생성자를 통해 객체 생성
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //cell 테두리
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
