//
//  FilterDropView.swift
//  YiLiang
//
//  Created by ecsage on 2022/6/18.
//  Copyright © 2022 iOSyan. All rights reserved.
//

import Foundation
import UIKit

enum FilterDropViewType {
    case time // 时间排序
    case most // 最高排序
    case staff // 运营人员(多选)
    case account // 账号(多选)
    case placeStatus // 投放状态
}

class FilterDropView: UIView, XYDropMenuProtocol {
    
    // XYDropMenuProtocol
    lazy var isDefaultSelected: Bool = false
    
    var selectedBlock: ((FilterDropModel) -> ())?
    
    @IBOutlet weak var tableView: UITableView!
    
    // 数据数组
    lazy var dataArray: [FilterDropModel] = (0..<6).map({_ in FilterDropModel()})
    
    lazy var type: FilterDropViewType = .time {
        didSet {
            if type == .time || type == .most {
                // 一进来选中第一行
                tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                isDefaultSelected = tableView.indexPathForSelectedRow != nil
            } else {
                tableView.allowsMultipleSelection = true
            }
        }
    }
    
    deinit {
        print("FilterDropView deinit")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    // MARK: - setupUI
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FilterDropView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        0.1
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        0.1
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FilterDropCell.cellForData(tableView, indexPath, dataArr: dataArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        
        guard dataArray.count > indexPath.row else {return}
        let model = dataArray[indexPath.row]
        if let selectedBlock = selectedBlock {
            selectedBlock(model)
        }
        
        isDefaultSelected = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        isDefaultSelected = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
        print(isDefaultSelected)
    }
}
