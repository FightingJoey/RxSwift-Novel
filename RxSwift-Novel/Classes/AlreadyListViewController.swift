//
//  AlreadyListViewController.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/9.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import HandyJSON

// 小说信息
struct NovelInfo: HandyJSON, Codable, DefaultsSerializable {
    // 小说名
    var title = ""
    // 小说路径
    var path = ""
    // 章节列表
    var sections: [SectionInfo] = []
    
    var currentIndex: Int = 0
    
    var currentSection: SectionInfo = SectionInfo()
    
    init() {}
}

// 章节信息
struct SectionInfo: HandyJSON, Codable, DefaultsSerializable {
    // 章节名
    var title = ""
    // 章节路径
    var path = ""
    
    init() {}
}

struct AlreadyModel: HandyJSON, Codable, DefaultsSerializable {

    var data: Dictionary<String, NovelInfo> = [:]
    
    init() {}
}

class AlreadyListViewController: UIViewController {

    var tableView: UITableView!
        
    var items = BehaviorSubject(value: [SectionModel<String,NovelInfo>]())
    
    let bag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, NovelInfo>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            let arr = element.title.split(separator: "/")
            cell.textLabel?.text = "\(String(arr.first ?? ""))" + " -> " + element.currentSection.title
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        },
        canEditRowAtIndexPath: { _,_ in
            return true
        }
    )
    
    var list: [NovelInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "已读列表"
        
        let dataSource = self.dataSource
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)

        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.itemDeleted.asObservable().subscribe(onNext: { [weak self] (index) in
            if let model = Defaults[\.alreadyReadList], let title = self?.list[index.row].title {
                var muModel = model
                muModel.data.removeValue(forKey: title)
                Defaults[\.alreadyReadList] = muModel
            }
            self?.getList()
        }).disposed(by: bag)
                
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                let vc = SectionListViewController()
                
                let novel = pair.1 as NovelInfo
                vc.path = novel.path
                vc.novelTitle = novel.title
                vc.currentIndexPath = novel.currentIndex

                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
        
    }
    
    func getList() {
        var result = [NovelInfo]()
        if let model = Defaults[\.alreadyReadList] {
            for item in model.data {
                result.append(item.value)
            }
        }
        list = result
        items.onNext([SectionModel(model: "", items: list)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getList()
    }

}

extension AlreadyListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
