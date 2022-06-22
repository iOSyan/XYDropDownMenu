//
//  FilterDropCell.swift
//  YiLiang
//
//  Created by ecsage on 2022/6/18.
//  Copyright © 2022 iOSyan. All rights reserved.
//

import UIKit

class FilterDropCell: UITableViewCell {

    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var checkImgView: UIImageView!
    
    var dataModel: FilterDropModel? = nil {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class func cellForData(_ tableView: UITableView, _ indexPath: IndexPath, dataArr: [Any]) -> Self {
        
        let reuseIdentifier = "FilterDropCell";
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = Bundle.main.loadNibNamed("FilterDropCell", owner: nil, options: nil)![0] as? UITableViewCell
        }
        
        if let cell = cell as? Self, dataArr.count > 0 {
            cell.dataModel = dataArr[indexPath.row] as? FilterDropModel
        }
        
        return cell as! Self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print("setSelected")
        checkImgView.isHidden = !selected
        desLabel.textColor = selected ? .blue : .black
        
    }

}
