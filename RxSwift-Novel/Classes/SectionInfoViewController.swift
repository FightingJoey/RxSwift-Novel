//
//  SectionInfoViewController.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/9.
//  Copyright © 2020 yu.qiao. All rights reserved.
//  章节详情

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kanna

class SectionInfoViewController: UIViewController {
    
    deinit {
        Dlog("SectionInfoViewController deinit")
    }
    
    var path: String = ""
    var sectionTitle: String = ""
    var novelTitle: String = ""
    
    var tableView: UITableView!
    
    let bag = DisposeBag()
    
    var disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SectionInfo>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = lineSpaceStr(attr: NSMutableAttributedString(string: element.title), font: UIFont.systemFont(ofSize: 20), space: 4)
            cell.backgroundColor = RGBColor(0xC7EDCC)
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
    )
    
    var items = BehaviorRelay(value: [SectionModel<String,SectionInfo>]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = sectionTitle

        let dataSource = self.dataSource
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
        tableView.estimatedRowHeight = 8000
        tableView.backgroundColor = RGBColor(0xC7EDCC)
        view.addSubview(tableView)
        
        let btn = UIButton(type: .system)
        btn.setTitle("下一章", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            var model = Defaults[\.alreadyReadList] ?? AlreadyModel()
            if let data = model.data[self?.novelTitle ?? ""] {
                var novel = data
                if novel.currentIndex < data.sections.count - 1 {
                    novel.currentIndex = novel.currentIndex + 1
                    novel.currentSection = novel.sections[novel.currentIndex]
                    model.data[self?.novelTitle ?? ""] = novel
                    Defaults[\.alreadyReadList] = model
                    
                    let path = novel.path + novel.sections[novel.currentIndex].path
                    self?.navigationItem.title = novel.sections[novel.currentIndex].title
                    self?.getSectionContent(path)
                }
            }
        }).disposed(by: bag)
        tableView.tableFooterView = btn
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        items.subscribe(onNext: { [weak self] (list) in
            if list.count > 0 {
                DispatchQueue.main.async {
                    self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
        }).disposed(by: bag)
        
        getSectionContent(path)
    }
    
    func getSectionContent(_ path: String) {
        HUD.show(.progress)
        _ = network.rx.request(.page(page: path))
            .flatMap { res -> Single<[SectionModel<String,SectionInfo>]> in
                guard let doc = try? HTML(html: res.data, encoding: .utf8) else {
                    return Single.create { single in
                        single(.error(NetError.message(text: "HTML解析错误")))
                        return Disposables.create()
                    }
                }
                var results = [SectionInfo]()
                var info = SectionInfo()
                let content = doc.xpath("//div[@id='content']").first?.content ?? ""
                info.title = content.replacingOccurrences(of: "    ", with: "\n\n")
                results.append(info)
                return Single.just([SectionModel(model: "", items: results)])
            }.asObservable().subscribe(onNext: { (data) in
                HUD.hide(animated: true)
                self.items.accept(data)
            }, onError: { (err) in
                Dlog(err)
            }, onCompleted: {
                Dlog("completed --------")
            }, onDisposed: {
                Dlog("dispose --------")
            })
        
    }

}

extension SectionInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
