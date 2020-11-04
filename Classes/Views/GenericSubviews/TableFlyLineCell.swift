//
//  TableFlyLineCell.swift
//  birdeye
//
//  Created by yu xiaohe on 2020/10/30.
//

import Foundation
import UIKit

class TableFlyLineCell: UITableViewCell {

    let width:CGFloat = UIScreen.main.bounds.width
    var userLabel:UILabel!      // 名字
    var birthdayLabel:UILabel!  // 出生日期
    var sexLabel:UILabel!       // 性别
    var iconImv:UIImageView!    // 头像
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 头像
        iconImv = UIImageView(frame: CGRect(x: 20, y: 15, width: 64, height: 64))
        iconImv.layer.masksToBounds = true
        iconImv.layer.cornerRadius = 5.0
        iconImv.backgroundColor = UIColor.yellow
        
        
        // 名字
        userLabel = UILabel(frame: CGRect(x: 94, y: 18, width: self.width-74-5, height: 15))
        userLabel.textColor = UIColor.black
        userLabel.font = UIFont.boldSystemFont(ofSize: 15)
        userLabel.textAlignment = .left
        
        // 性别
        sexLabel = UILabel(frame: CGRect(x: 94, y: 49, width: self.width-74-5, height: 13))
        sexLabel.textColor = UIColor.black
        sexLabel.font = UIFont.systemFont(ofSize: 13)
        sexLabel.textAlignment = .left
        
        // 出生日期
        birthdayLabel = UILabel(frame: CGRect(x: 94, y: 80, width: width-94, height: 13))
        birthdayLabel.textColor = UIColor.gray
        birthdayLabel.font = UIFont.systemFont(ofSize: 13)
        birthdayLabel.textAlignment = .left
        
        contentView.addSubview(iconImv)
        contentView.addSubview(userLabel)
        contentView.addSubview(sexLabel)
        contentView.addSubview(birthdayLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
