//
//  ViewerGoLiveViewController.swift
//  NerveLive
//
//  Created by wbx on 2023/12/21.
//

import UIKit
import SVProgressHUD

/// viewer角色前往直播页面
class ViewerGoLiveViewController: BaseViewController {

    var dataArray = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(menuBtn)
        view.addSubview(table)
        self.dataArray.append(User())
        table.reloadData()

        /*SVProgressHUD.show()
        LoginBackend.shared.queryUserList { users in
            self.dataArray.removeAll()
            for (_, user) in users.enumerated() {
                if user.isMaster ?? false {
                    self.dataArray.append(user)
                }
            }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.table.reloadData()
            }
        } fail: { msg in
            debugPrint("直播列表请求失败")
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }*/
    }

    lazy var table: UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: menuBtn.frame.maxY, width: K_WINDOW_WIDTH(), height: K_WINDOW_HEIGHT() - menuBtn.frame.maxY), style: .grouped)
        table.backgroundColor = UIColor.clear
        table.rowHeight = UITableView.automaticDimension
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.estimatedRowHeight = 0.01
        table.estimatedSectionHeaderHeight = 0.01
        table.estimatedSectionFooterHeight = 0.01
        table.register(MasterLiveCell.self, forCellReuseIdentifier: "MasterLiveCell")
        table.isScrollEnabled = false
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        return table
    }()

    lazy var menuBtn: UIButton = {
        let menuBtn = UIButton(frame: CGRect(x: K_SCREEN_WIDTH - 22 - 48, y: K_SAFEAREA_TOP_HEIGHT(), width: 48, height: 48))
        menuBtn.backgroundColor = .clear
        menuBtn.setImage(UIImage(named: "icon_line_menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(menuBtnClick), for: .touchUpInside)
        return menuBtn
    }()

    @objc func menuBtnClick() {
        let vc = SettingViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension ViewerGoLiveViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MasterLiveCell.cellForHeight()
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MasterLiveCell = tableView.dequeueReusableCell(withIdentifier: "MasterLiveCell", for: indexPath) as! MasterLiveCell
        let user = dataArray[indexPath.section]
        cell.master = user
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*if let user: User = dataArray[indexPath.section] as? User {

        }*/
    }
}
