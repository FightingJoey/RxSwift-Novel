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
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SectionInfo>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = lineSpaceStr(attr: NSMutableAttributedString(string: element.title), font: UIFont.systemFont(ofSize: 20), space: 4)
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
        view.addSubview(tableView)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        Dlog(path)
        getSectionContent(path)
    }
    
    func getSectionContent(_ path: String) {
        network.rx.request(.page(page: path)).flatMap { res -> Single<[SectionModel<String,SectionInfo>]> in
            let coding  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let str = String(data: res.data, encoding: String.Encoding(rawValue: coding))
            guard let data = str, let doc = try? HTML(html: data, encoding: .utf8) else {
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
            self.items.accept(self.items.value + data)
        }, onError: { (err) in
            Dlog(err)
        }).disposed(by: bag)
    }

}

extension SectionInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer")
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64)
        btn.setTitle("下一章", for: .normal)
        btn.rx.tap.subscribe(onNext: {
            
            var model = Defaults[\.alreadyReadList] ?? AlreadyModel()
            if let data = model.data[self.novelTitle] {
                var novel = data
                if novel.currentIndex < data.sections.count - 1 {
                    novel.currentIndex = novel.currentIndex + 1
                    novel.currentSection = novel.sections[novel.currentIndex]
                    model.data[self.novelTitle] = novel
                    Defaults[\.alreadyReadList] = model
                    
                    let path = novel.path + novel.sections[novel.currentIndex].path
                    self.navigationItem.title = novel.sections[novel.currentIndex].title
                    self.getSectionContent(path)
                }
            }

        }).disposed(by: bag)
        
        footer?.addSubview(btn)
        
        return btn
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 64
    }
}
