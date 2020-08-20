//
//  UIScrollViewExtension.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/20.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit

//MARK: UIScrollView
private var kDefaultRefreshHeader: String = "kDefaultRefreshHeader"
private var kDefaultRefreshFooter: String = "kDefaultRefreshFooter"

extension UIScrollView {
    
    var header: DefaultRefreshHeader? {
        get {
            return (objc_getAssociatedObject(self, &kDefaultRefreshHeader) as? DefaultRefreshHeader)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kDefaultRefreshHeader, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var footer: DefaultRefreshFooter? {
        get {
            return (objc_getAssociatedObject(self, &kDefaultRefreshFooter) as? DefaultRefreshFooter)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kDefaultRefreshFooter, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addRefreshHeader(_ vc: AnyObject, action: @escaping () -> ()) {
        header = DefaultRefreshHeader.header()
        header?.setText("下拉可以刷新", mode: .pullToRefresh)
        header?.setText("松开立即刷新", mode: .releaseToRefresh)
        header?.setText("刷新成功", mode: .refreshSuccess)
        header?.setText("正在刷新数据中...", mode: .refreshing)
        header?.setText("刷新失败", mode: .refreshFailure)
        self.configRefreshHeader(with: header!, container: vc, action: action)
    }
    
    func updateRefreshHeader(to state:HeaderRefresherState, _ result:RefreshResult) {
        self.switchRefreshHeader(to: state)
    }
    
    func addRefreshFooter(_ vc: AnyObject, action: @escaping () -> ()) {
        footer = DefaultRefreshFooter.footer()
        footer?.textLabel.font = UIFont.systemFont(ofSize: 15)
        footer?.textLabel.numberOfLines = 0
        footer?.setText(NSAttributedString(string: "上拉或点击加载更多"), mode: .scrollAndTapToRefresh)
        footer?.setText(NSAttributedString(string: "没有更多啦"), mode: .noMoreData)
        footer?.setText(NSAttributedString(string: "正在加载中..."), mode: .refreshing)
        self.configRefreshFooter(with: footer!, container: vc, action: action)
    }
    
    func hasHeader() -> Bool {
        var hasHeader: Bool = false
        for view in self.subviews {
            if view is RefreshableHeader {
                hasHeader = true
            }
        }
        return hasHeader
    }
    
    func hasFooter() -> Bool {
        var hasFooter: Bool = false
        for view in self.subviews {
            if view is RefreshableFooter {
                hasFooter = true
            }
        }
        return hasFooter
    }
    
}
