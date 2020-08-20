//
//  ViewController.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/6.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!

    let bag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, NovelInfo>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "listcell")!
            cell.textLabel?.text = element.title
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
    )
    
    let keywords = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                let vc = SectionListViewController()
                vc.path = pair.1.path
                vc.novelTitle = pair.1.title

                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
        
        let searchResultList: Driver<[SectionModel<String, NovelInfo>]> = keywords.asDriver(onErrorJustReturn: "").filter { text in
            if text.count == 0 {
                return true
            }
            let match: String = "(^[\\u4e00-\\u9fa5]+$)"
            let predicate = NSPredicate(format: "SELF matches %@", match)
            return predicate.evaluate(with: text)
        }.flatMapLatest({ keyword in
            if keyword.count == 0 {
                return Driver.just([SectionModel(model: "", items: [])])
            }
            HUD.show(.progress)
            return network.rx.request(.search(keyword: keyword)).mapNovelInfo().asDriver(onErrorJustReturn: [NovelInfo]()).map { res in
                return [SectionModel(model: keyword, items: res)]
            }
        })
        searchResultList.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        searchResultList.drive(onNext: { (_) in
            HUD.hide(animated: true)
        }).disposed(by: bag)
        
        searchBar.rx.text.orEmpty.filter { $0.count == 0 }.subscribe(onNext: { [weak self] (_) in
            self?.keywords.onNext("")
        }).disposed(by: bag)
        
        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            self?.searchBar.resignFirstResponder()
            self?.keywords.onNext(self?.searchBar.text ?? "")
        }).disposed(by: bag)
        
    }
    
    @IBAction func alreadyBtnClicked(_ sender: Any) {
        let vc = AlreadyListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
}

