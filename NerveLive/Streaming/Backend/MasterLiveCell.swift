//
//  MasterLiveCell.swift
//  NerveLive
//
//  Created by wbx on 2023/12/21.
//

import UIKit

class MasterLiveCell: UITableViewCell {

    private var _master: User?
    var master: User? {
        get { return _master }
        set {
            _master = newValue
            updateData()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(avatarBtn)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(tikTokLabel)
        contentView.addSubview(imgView)
    }

    func updateData() {
        guard let _master = _master else { return }

        let lastName = _master.firstName ?? "Ryan"
        let isLive = _master.isLive ?? false

        nameLabel.text = "\(lastName) is \(isLive ? "ONLINE" : "going live soon")"
        descLabel.text = "You’ll be notified when Ryan goes Live."
        tikTokLabel.text = "TikTok: @rahultok_        IG: @ryanxietv"
    }

    lazy var avatarBtn: UIButton = {
        let avatarBtn = UIButton(type: .custom)
        avatarBtn.frame = CGRect(x: 38 , y: 0, width: 40, height: 40)
        avatarBtn.backgroundColor = .clear
        avatarBtn.setImage(UIImage(named: "icon_default_avatar"), for: .normal)
        // avatarBtn.addTarget(self, action: #selector(avatarBtnBtnClicked), for: .touchUpInside)
        return avatarBtn
    }()

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: CGRectGetMaxX(avatarBtn.frame) + 8, y: avatarBtn.frame.minY + 3, width: K_SCREEN_WIDTH - avatarBtn.frame.maxX - 8 - 38, height: 16)
        nameLabel.font = .font(ofSize: 14, type: .SemiBold)
        nameLabel.textColor = K_VIEW_WHITECOLOR
        return nameLabel
    }()

    lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        //descLabel.frame = CGRect(x: CGRectGetMaxX(avatarBtn.frame) + 8, y: nameLabel.frame.maxY + 3, width: K_SCREEN_WIDTH - avatarBtn.frame.maxX - 8 - 38, height: 34)
        descLabel.frame = CGRect(x: CGRectGetMaxX(avatarBtn.frame) + 8, y: nameLabel.frame.maxY + 3, width: K_SCREEN_WIDTH - avatarBtn.frame.maxX - 8 - 38, height: 15)
        descLabel.font = .font(ofSize: 14, type: .Regular)
        descLabel.textColor = K_VIEW_WHITECOLOR
        descLabel.numberOfLines = 2
        return descLabel
    }()

    lazy var tikTokLabel: UILabel = {
        //let tikTokLabel = UILabel(frame: CGRect(x: CGRectGetMaxX(avatarBtn.frame) + 8, y: descLabel.frame.maxY + 5, width: K_SCREEN_WIDTH - avatarBtn.frame.maxX - 8 - 38, height: 17))
        let tikTokLabel = UILabel(frame: CGRect(x: CGRectGetMaxX(avatarBtn.frame) + 8, y: descLabel.frame.maxY + 19 + 5, width: K_SCREEN_WIDTH - avatarBtn.frame.maxX - 8 - 38, height: 17))
        tikTokLabel.font = .font(ofSize: 14, type: .Regular)
        tikTokLabel.textColor = K_VIEW_WHITECOLOR
        return tikTokLabel
    }()

    lazy var imgView: UIImageView = {
        let width = K_SCREEN_WIDTH - 105 * 2
        let height = width * 385.0 / 178.0
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 105, y: tikTokLabel.frame.maxY + 10, width: width, height: height)
        imgView.image = UIImage(named: "icon_default_live_img")
        return imgView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func cellForHeight() -> CGFloat {
        let width = K_SCREEN_WIDTH - 105 * 2
        let height = width * 385.0 / 178.0
        // 间隔+nameLabel+间隔+descLabel+间隔+tikTokLabel+间隔+height+间隔
        return 3 + 16 + 3 + 34 + 5 + 17 + 10 + height + 16
    }
}
