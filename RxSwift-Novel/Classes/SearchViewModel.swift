//
//  SearchViewModel.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/9.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class SearchViewModel {
    
    deinit {
        Dlog("SearchViewModel deinit")
    }
    
    let searchResultList: Driver<[SectionModel<String, NovelInfo>]>

    init(keyword: Driver<String>) {
        searchResultList = keyword.filter({ (text) in
            if text.count == 0 {
                return true
            }
            let match: String = "(^[\\u4e00-\\u9fa5]+$)"
            let predicate = NSPredicate(format: "SELF matches %@", match)
            return predicate.evaluate(with: text)
        }).flatMapLatest({ keyword in
            if keyword.count == 0 {
                return Driver.just([SectionModel(model: "", items: [])])
            }
            HUD.show(.progress)
            return network.rx.request(.search(keyword: keyword)).mapNovelInfo().asDriver(onErrorJustReturn: [NovelInfo]()).map { res in
                return [SectionModel(model: keyword, items: res)]
            }
        })
    }
}
