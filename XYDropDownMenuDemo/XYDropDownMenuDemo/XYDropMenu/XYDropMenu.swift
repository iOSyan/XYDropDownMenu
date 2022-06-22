//
//  XYDropMenu.swift
//  YiLiang
//
//  Created by ecsage on 2022/6/17.
//  Copyright © 2022 iOSyan. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

protocol XYDropMenuProtocol: UIView {
    var isDefaultSelected: Bool { set get }
}

class XYDropMenu: UIView {
    
    lazy var isOpened: Bool = false
    
    // 必须要遵守XYDropMenuDefaultSelected协议的view才能当子view
    var dropDownViews: [XYDropMenuProtocol]? {
        didSet {
            guard dropDownViews?.count == dropDownTitles?.count else {
                fatalError("请确保 dropDownViews count 跟 dropDownTitles count数量一样")
            }
            
            guard let dropDownViews = dropDownViews, dropDownViews.count > 0 else { return }
            
            dropDownViewsHeights = dropDownViews.map({$0.height})
            
            // 在这里设置是否默认选中了menu
            judgeIfDefaultSelected()
        }
    }
    
    lazy var dropDownViewsHeights: [CGFloat] = []
    
    var dropDownTitles: [String]? {
        didSet {
            setupStackSubviews()
        }
    }
    
    var titleBtns: [UIButton]?
    
    lazy var isShowArr: [Bool] = []
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()
    
    /// 遮罩view
    lazy var coverBgView: UIButton? = {
        let coverBgView = UIButton(type: .custom)
        coverBgView.backgroundColor = .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        coverBgView.addTarget(self, action: #selector(coverBgViewClick(_:)), for: .touchUpInside)
        return coverBgView
    }()
    
    var selectedIndex: Int?
    
    var selectedBtn: UIButton? {
        get {
            if let selectedIndex = selectedIndex {
                return titleBtns?[selectedIndex]
            }
            return nil
        }
    }
    
    var showingDropView: UIView? {
        get {
            if let selectedIndex = selectedIndex {
                return dropDownViews?[selectedIndex]
            }
            return nil
        }
    }
    
    var showingDropViewHeight: CGFloat {
        get {
            if let selectedIndex = selectedIndex, dropDownViewsHeights.count > 0 {
                return dropDownViewsHeights[selectedIndex]
            }
            return 0
        }
    }
    
    
    // MARK: - lift cycle
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.frame = bounds
        
        let originY = y + height
        coverBgView?.frame = CGRect(x: 0, y: originY, width: width, height: UIScreen.main.bounds.size.height - originY)
    }
    
}

// MARK: - 对外的接口
extension XYDropMenu {
    
    // MARK: 更新标题的选中状态
    func refreshSelectedTitle(index: Int, title: String = "") {
        guard let titleBtns = titleBtns, index < titleBtns.count else {return}
        
        let btn = titleBtns[index]
        if !title.isEmpty {
            btn.setTitle(title, for: .normal)
        }
        
        btn.isSelected = true
    }
    
    
    // MARK: 隐藏drop View
    func hideDropView() {
        guard isOpened else { return }
        
        guard let coverBgView = coverBgView, let showingDropView = showingDropView else {return}
        
        // 关闭了则将所有按钮都置为关闭状态
        isShowArr = isShowArr.map({_ in false})
        
        weak var weakSelf = self
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: []) {
            coverBgView.alpha = 0
            showingDropView.height = 0
        } completion: { _ in
            showingDropView.height = weakSelf?.showingDropViewHeight ?? 0
            coverBgView.removeFromSuperview()
            showingDropView.removeFromSuperview()
            weakSelf?.isOpened = !weakSelf!.isOpened
        }
    }
}

// MARK: - private
private extension XYDropMenu {
    
    // MARK: - setupUI
    func setup() {
        setupStackView()
    }
    
    func setupStackView() {
        stackView.backgroundColor = .gray
        addSubview(stackView)
    }
    
    func setupStackSubviews() {
        guard let dropDownTitles = dropDownTitles, dropDownTitles.count > 0 else {return}
        
        // 删除stackView上所有view
        removeAllArrangedSubview()
        titleBtns = []
        
        for index in 0..<dropDownTitles.count {
            let title = dropDownTitles[index]
            if title.isEmpty { continue }
            
            let button = UIButton(type: .custom)
            button.tag = index
//            button.setupButtonImageAndTitlePossitionWith(padding: 5, style: .imageIsRight)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(.lightGray, for: .normal)
            button.setTitleColor(.blue, for: .selected)
            button.addTarget(self, action: #selector(titleBtnClick(sender:)), for: .touchUpInside)
            button.backgroundColor = .yellow
            titleBtns?.append(button)
            isShowArr.append(false)
            stackView.addArrangedSubview(button)
        }
    }
    
    // 删除stackView上所有view
    func removeAllArrangedSubview() {
        guard let titleBtns = titleBtns, titleBtns.count > 0 else {return}
        for btn in titleBtns {
            stackView.removeArrangedSubview(btn)
        }
    }
    
    // MARK: - 隐藏或显示
    func showOrHideDropView(isShow: Bool) {
        isShow ? showDropView() : hideDropView()
    }
    
    func showDropView() {
//        guard
//            let selectedBtn = selectedBtn,
//            let showingDropView = showingDropView else { return }
            
        guard let coverBgView = coverBgView, let showingDropView = showingDropView else {return}
        
        superview?.addSubview(coverBgView)
        
        showingDropView.y = y + height
        showingDropView.height = 0
        superview?.addSubview(showingDropView)
//        showingDropView.isHidden = false
        
        weak var weakSelf = self
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: []) {
            coverBgView.alpha = 1.0
            showingDropView.height = weakSelf?.showingDropViewHeight ?? 0
        } completion: { _ in }
        
        isOpened = true
    }
    
    // 是否默认选中了menu
    func judgeIfDefaultSelected() {
        guard let dropDownViews = dropDownViews, dropDownViews.count > 0 else { return }
        
        for index in 0..<dropDownViews.count {
            let view = dropDownViews[index]
            if view.isDefaultSelected, let titleBtns = titleBtns {
                let btn = titleBtns[index]
                btn.isSelected = true
            }
        }
    }
    
    // MARK: - 点击事件
    @objc func titleBtnClick(sender: UIButton) {
        var isShow = isShowArr[sender.tag]
        isShow = !isShow
        
        // 如果是点击了另外的按钮
        if selectedBtn != sender {
            isShow = true
            
            // 先隐藏上一个
            if showingDropView != nil {
                showingDropView?.removeFromSuperview()
            }
            
            selectedIndex = sender.tag
        }
        
        // 显示
        showOrHideDropView(isShow: isShow)
        isShowArr[sender.tag] = isShow
    }
    
    // 点击遮罩view
    @objc func coverBgViewClick(_ sender: UIButton) {
        hideDropView()
    }
}


extension UIView {
    //x position
    var x : CGFloat{
        get {
            return frame.origin.x

        }
        set(newVal) {
            var tempFrame : CGRect = frame
            tempFrame.origin.x     = newVal
            frame                  = tempFrame
        }
    }

    //y position
    var y : CGFloat{
        get {
            return frame.origin.y
        }
        set(newVal) {
            var tempFrame : CGRect = frame
            tempFrame.origin.y     = newVal
            frame                  = tempFrame
        }
    }
    
    //size
    var size : CGSize {
        get {
            return CGSize(width: frame.size.width, height: frame.size.height)
        }
        set(newVal) {
            var tmpSize : CGSize = frame.size
            tmpSize              = newVal
            frame.size           = tmpSize
        }
    }

    //height
    var height : CGFloat{
        get {
            return frame.size.height
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.height  = newVal
            frame                 = tmpFrame
        }
    }


    // width
    var width : CGFloat {
        get {
            return frame.size.width
        }
        set(newVal) {
            var tmpFrame : CGRect = frame
            tmpFrame.size.width   = newVal
            frame                 = tmpFrame
        }
    }

    // left
    var left : CGFloat {
        get {
            return x
        }
        set(newVal) {
            x = newVal
        }
    }

    // right
    var right : CGFloat {
        get {
            return x + width
        }
        set(newVal) {
            x = newVal - width
        }
    }

    // top
    var top : CGFloat {
        get {
            return y
        }
        set(newVal) {
            y = newVal
        }
    }

    // bottom
    var bottom : CGFloat {
        get {
            return y + height
        }

        set(newVal) {
            y = newVal - height
        }
    }

    //centerX
    var centerX : CGFloat {
        get {
            return center.x
        }
        set(newVal) {
            center = CGPoint(x: newVal, y: center.y)
        }
    }

    //centerY
    var centerY : CGFloat {
        get {
            return center.y
        }

        set(newVal) {
            center = CGPoint(x: center.x, y: newVal)
        }
    }
    
    //middleX
    var middleX : CGFloat {
        get {
            return width / 2
        }
    }

    //middleY
    var middleY : CGFloat {
        get {
            return height / 2
        }
    }

    //middlePoint
    var middlePoint : CGPoint {
        get {
            return CGPoint(x: middleX, y: middleY)
        }
    }
    
    var maxX : CGFloat {
        get {
            return frame.maxX
        }
    }
    
    var minX : CGFloat {
        get {
            return frame.minX
        }
    }
    
    var maxY : CGFloat {
        get {
            return frame.maxY
        }
    }
    
    var minY : CGFloat {
        get {
            return frame.minY
        }
    }
}
