//
//  SectionListViewController.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/9.
//  Copyright © 2020 yu.qiao. All rights reserved.
//  章节列表

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kanna

class SectionListViewController: UIViewController {
    
    var path: String = ""
    var novelTitle: String = ""
    var currentIndexPath: Int = 0
    
    var tableView: UITableView!
    
    let bag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, SectionInfo>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.selectionStyle = .none
            cell.textLabel?.text = element.title
            return cell
        },
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
    )
    
    var sections: [SectionInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = novelTitle
        
        let dataSource = self.dataSource
        let path = self.path
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        network.rx.request(.page(page: path)).flatMap { res -> Single<[SectionInfo]> in
            let coding  = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
            let str = String(data: res.data, encoding: String.Encoding(rawValue: coding))
            guard let data = str, let doc = try? HTML(html: data, encoding: .utf8) else {
                return Single.create { single in
                    single(.error(NetError.message(text: "HTML解析错误")))
                    return Disposables.create()
                }
            }
            let divs = doc.xpath("//div[@id='list']").first!.css("dl > dd")
            var results = [SectionInfo]()
            for link in divs {
                var data = SectionInfo()
                data.title = link.css("a").first?.text ?? ""
                data.path = link.css("a").first?["href"] ?? ""
                results.append(data)
            }
            self.sections = results
            return Single.just(results)
        }.asDriver(onErrorJustReturn: [SectionInfo]()).map { res in
            return [SectionModel(model: "", items: res)]
        }.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
        
        tableView.rx
            .itemSelected
            .map { indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { pair in
                let vc = SectionInfoViewController()
                vc.path = path + pair.1.path
                vc.sectionTitle = pair.1.title
                vc.novelTitle = self.novelTitle
                
                var model = Defaults[\.alreadyReadList] ?? AlreadyModel()
                var novel = NovelInfo()
                novel.title = self.novelTitle
                novel.path = self.path
                novel.sections = self.sections
                novel.currentIndex = pair.0.row
                novel.currentSection = pair.1 as SectionInfo
                model.data[self.novelTitle] = novel
                Defaults[\.alreadyReadList] = model
                
                self.currentIndexPath = pair.0.row
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentIndexPath != 0 {
            tableView.scrollToRow(at: IndexPath(row: currentIndexPath, section: 0), at: .bottom, animated: true)
        }
    }
    
}

extension SectionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
}
