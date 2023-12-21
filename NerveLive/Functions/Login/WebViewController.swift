//
//  WebViewController.swift
//  Nerve
//
//  Created by 殷聃 on 2023/10/6.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String = "" // 设置要加载的URL字符串

    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建WKWebView并设置代理
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView

        // 创建URL对象
        if let url = URL(string: urlString) {
            // 创建URL请求
            let request = URLRequest(url: url)
            // 加载URL请求
            webView.load(request)
        }
    }

    // WKNavigationDelegate方法：页面加载完成时调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 页面加载完成后的处理
    }

    // WKNavigationDelegate方法：页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 页面加载失败后的处理
    }
}

