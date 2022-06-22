//
//  ViewController.swift
//  XYDropDownMenuDemo
//
//  Created by ecsage on 2022/6/21.
//

import UIKit

/// 屏幕大小
let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    @IBOutlet weak var dropMenu: XYDropMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropMenu.dropDownTitles = ["自定义", "单选", "多选"]
        
        // 任意自定义View
        let view = UIView()
        view.backgroundColor = .yellow
        view.width = kScreenWidth
        view.height = 300
        
        // 单选
        let view2 = FilterDropView.loadFromNib()
        view2.type = .single
        view2.width = kScreenWidth
        view2.height = 100
        weak var weakSelf = self
        view2.selectedBlock = { model in
            weakSelf?.dropMenu.refreshSelectedTitle(index: 1, title: "gggg")
            weakSelf?.dropMenu.hideDropView()
        }
        
        // 可以多选
        let view3 = FilterDropView.loadFromNib()
        view3.type = .multiple
        view3.width = kScreenWidth
        view3.height = 350
        view3.selectedBlock = { model in
            weakSelf?.dropMenu.refreshSelectedTitle(index: 2)
            weakSelf?.dropMenu.hideDropView()
        }

        dropMenu.dropDownViews = [view, view2, view3]
    }
}

/// 加载xib
extension UIView {
    static func loadFromNib(_ nibname: String? = nil, index: Int = 0) -> Self { // Self(大写)当前类对象
        /// self(小写)当前对象
        let loadName = nibname == nil ? "\(Self.self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)![index] as! Self
    }
}
