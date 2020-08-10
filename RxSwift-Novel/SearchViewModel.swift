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
        searchResultList = keyword.flatMapLatest({ keyword in
            return network.rx.request(.search(keyword: keyword)).mapNovelInfo().asDriver(onErrorJustReturn: [NovelInfo]()).map { res in
                return [SectionModel(model: keyword, items: res)]
            }
        })
    }
}
