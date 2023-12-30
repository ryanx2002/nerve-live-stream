//
//  VenmoEditConfirmationView.swift
//  Nerve
//
//  Created by wbx on 2023/9/20.
//

import UIKit

/// 验证码输入视图
class VenmoEditConfirmationView: UIView {
    typealias VenmoEditDidChanged = (_ value: String) -> Void
    typealias VenmoEditFinished = (_ value: String) -> Void

    var venmoEditDidChanged: VenmoEditDidChanged? // 编辑回调
    var venmoEditFinished: VenmoEditFinished? // 编辑完成回调

    var itemCount: Int = 4 // item count
    var itemSpace: CGFloat = 10 // default 20
    var itemSize: CGSize = CGSize(width: 60, height: 80) // item size

    private var labels = [UILabel?]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(textField)
        addSubview(maskBtn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        textField.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        maskBtn.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

        let itemsWidth = itemSize.width * CGFloat(itemCount)
        let spacesWidth = itemSpace * (CGFloat(itemCount) - 1)
        let contentWidth = itemsWidth + spacesWidth
        let originX = (frame.width - contentWidth) / 2

        for i in 0..<itemCount {
            var label: UILabel?
            if labels.count < itemCount {
                label = UILabel()
            } else {
                label = labels[i]
            }
            guard let label = label else {
                return
            }
            label.frame = CGRect(x: originX + (itemSize.width + itemSpace) * CGFloat(i), y: 0, width: itemSize.width, height: itemSize.height)
            label.backgroundColor = K_VIEW_WHITECOLOR
            if (label.text ?? "").count <= 0 {
                label.backgroundColor = UIColor.hexColorWithAlpha(color: DEFAUT_TEXT_BG, alpha: 1)
            } else {
                label.backgroundColor = UIColor.hexColorWithAlpha(color: HIGHLIGHT_TEXT_BG, alpha: 1)
            }
            label.textColor = K_VIEW_BLACKCOLOR
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
            label.font = .font(ofSize: 48, type: .Regular)
            label.textAlignment = .center
            addSubview(label)
            labels.append(label)
        }
    }

    lazy var textField: NETextField = {
        let textField = NETextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        textField.backgroundColor = K_VIEW_WHITECOLOR
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        textField.textColor = .clear
        textField.addTarget(self, action: #selector(textFieldChanged(sender:)), for: .editingChanged)
        textField.becomeFirstResponder()
        textField.delegate = self
        return textField
    }()

    lazy var maskBtn: UIButton = {
        let maskBtn = UIButton(type: .custom)
        maskBtn.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        maskBtn.backgroundColor = K_VIEW_BLACKCOLOR
        maskBtn.addTarget(self, action: #selector(maskBtnClicked), for: .touchUpInside)

        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        maskBtn.addGestureRecognizer(longGesture)
        return maskBtn
    }()

    @objc func longPress() {
        showMenu()
    }

    @objc func maskBtnClicked() {
        textField.becomeFirstResponder()
    }

    @objc func textFieldChanged(sender: UITextField) {
        let value: NSString = (textField.text ?? "") as NSString
        if value.length > itemCount {
            textField.text = value.substring(with: NSRange(location: 0, length: itemCount))
        }
        for i in 0..<itemCount {
            let label = labels[i]
            guard let label = label else { return }
            let textValue = (textField.text ?? "") as NSString
            if i < textValue.length {
                label.text = textValue.substring(with: NSRange(location: i, length: 1))
                label.backgroundColor = UIColor.hexColorWithAlpha(color: HIGHLIGHT_TEXT_BG, alpha: 1)
            } else {
                label.text = nil
                label.backgroundColor = UIColor.hexColorWithAlpha(color: DEFAUT_TEXT_BG, alpha: 1)
            }
        }

        if (textField.text ?? "").count >= itemCount {
            if let callback = venmoEditFinished {
                callback(textField.text ?? "")
            }
        } else {
            if let callback = venmoEditDidChanged {
                callback(textField.text ?? "")
            }
        }
    }

    func showMenu() {
        let copyItem = UIMenuItem(title: "Copy", action: #selector(copyItemAction(menu:)))
        let pasteItem = UIMenuItem(title: "Paste", action: #selector(pasteItemAction(menu:)))
        let menu = UIMenuController.shared
        menu.menuItems = [copyItem, pasteItem]
        menu.showMenu(from: superview!, rect: frame)
        // menu.setMenuVisible(true, animated: true)
    }

    /// copy
    @objc func copyItemAction(menu: UIMenuController) {
        UIPasteboard.general.string = textField.text
    }

    /// paste
    @objc func pasteItemAction(menu: UIMenuController) {
        let text: String = UIPasteboard.general.string ?? ""
        textField.text = text
        textFieldChanged(sender: textField)
        let position = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: position, to: position)
    }
}

extension VenmoEditConfirmationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if (textField.text ?? "").count >= itemCount {
//            if let callback = venmoEditFinished {
//                callback(textField.text ?? "")
//            }
//        }
        return true;
    }
}

class NETextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) ||
            action == #selector(selectAll(_:)) ||
            action == #selector(select(_:)){
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

