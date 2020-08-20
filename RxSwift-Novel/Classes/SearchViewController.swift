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
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        let dataSource = self.dataSource
        
//        let keyword = searchBar.rx.searchButtonClicked.asDriver().withLatestFrom(searchBar.rx.text.orEmpty.asDriver())
//        let keyword = Driver<String>.combineLatest(searchBar.rx.searchButtonClicked.asDriver(), searchBar.rx.text.orEmpty.asDriver()) { (s1, s2) in
//            return s2
//        }
        viewModel = SearchViewModel(keyword: searchBar.rx.text.orEmpty.asDriver())
        viewModel.searchResultList.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        viewModel.searchResultList.drive(onNext: { (_) in
            HUD.hide(animated: true)
        }).disposed(by: bag)
        
        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            self?.searchBar.resignFirstResponder()
        }).disposed(by: bag)
        
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

