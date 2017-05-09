//
//  MemoCell.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class MemoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var memo: Memo? {
        didSet {
            titleLabel.text = memo?.title
            dateLabel.text = memo?.dateString
            timeLabel.text = memo?.timeString
        }
    }
}
