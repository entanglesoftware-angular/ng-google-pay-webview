import Foundation
import Capacitor
import WebKit
import UIKit

@objc(NgGooglePayWebviewPlugin)
public class NgGooglePayWebviewPlugin: CAPPlugin, WKUIDelegate {

  private var popupWebViews: [WKWebView] = []
  private var dimView: UIView?
  private var popupContainerView: UIView?
  private var closeButton: UIButton?

  // Auto-run when plugin loads (no JS call required)
  public override func load() {
    NSLog("✅ NgGooglePayWebviewPlugin load() fired")
    DispatchQueue.main.async {
      self.applyFixes()
    }
  }

  // Optional manual call
  @objc func setup(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      self.applyFixes()
      call.resolve()
    }
  }

private func applyFixes() {
  guard let webView = self.bridge?.webView else { return }

  // 1) Append UA suffix
  let suffix = " GOOGLE_PAY_SUPPORTED"

  let existingUA = webView.customUserAgent ?? ""
  let willChange = !existingUA.contains(suffix)

  if willChange {
    webView.customUserAgent = existingUA + suffix
  }

  // 2) Popup support
  webView.uiDelegate = self

  // 3) If UA changed, reload ONCE so JS sees it early
  if willChange {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      webView.reload()
    }
  }
}

  // MARK: - WKUIDelegate popup support

  public func webView(_ webView: WKWebView,
                      createWebViewWith configuration: WKWebViewConfiguration,
                      for navigationAction: WKNavigationAction,
                      windowFeatures: WKWindowFeatures) -> WKWebView? {

    guard navigationAction.targetFrame == nil else { return nil }

    let popup = WKWebView(frame: .zero, configuration: configuration)
    popup.uiDelegate = self
    addPopupBottomSheet(popup)
    popupWebViews.append(popup)
    return popup
  }

  public func webViewDidClose(_ webView: WKWebView) {
    if webView == self.bridge?.webView { return }

    if let container = popupContainerView, let root = self.bridge?.viewController?.view {
      UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
        container.transform = CGAffineTransform(translationX: 0, y: root.bounds.height)
        self.dimView?.alpha = 0
        self.closeButton?.alpha = 0
      }, completion: { _ in
        webView.removeFromSuperview()
        container.removeFromSuperview()
        self.popupContainerView = nil
        self.dimView?.removeFromSuperview()
        self.dimView = nil
        self.closeButton?.removeFromSuperview()
        self.closeButton = nil
      })
    } else {
      webView.removeFromSuperview()
      dimView?.removeFromSuperview()
      dimView = nil
      closeButton?.removeFromSuperview()
      closeButton = nil
    }

    popupWebViews.removeAll { $0 == webView }
  }

  // MARK: - Bottom-sheet UI

  private func addPopupBottomSheet(_ webView: WKWebView) {
    guard let root = self.bridge?.viewController?.view else { return }

    // Dim overlay
    let dim = UIView()
    dim.translatesAutoresizingMaskIntoConstraints = false
    dim.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    dim.alpha = 0
    root.addSubview(dim)
    NSLayoutConstraint.activate([
      dim.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      dim.topAnchor.constraint(equalTo: root.topAnchor),
      dim.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      dim.bottomAnchor.constraint(equalTo: root.bottomAnchor)
    ])
    dimView = dim

    // Container
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .white
    container.layer.cornerRadius = 16
    container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    container.clipsToBounds = true
    root.addSubview(container)

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      container.trailingAnchor.constraint(equalTo: root.trailingAnchor),
      container.bottomAnchor.constraint(equalTo: root.bottomAnchor),
      container.heightAnchor.constraint(equalTo: root.heightAnchor, multiplier: 0.7)
    ])
    popupContainerView = container

    // WebView inside
    webView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(webView)
    NSLayoutConstraint.activate([
      webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      webView.topAnchor.constraint(equalTo: container.topAnchor, constant: 50),
      webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    addCloseButton(to: container)

    // Animate up
    container.transform = CGAffineTransform(translationX: 0, y: root.bounds.height)
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
      container.transform = .identity
      dim.alpha = 1
    }, completion: nil)
  }

  private func addCloseButton(to container: UIView) {
    let size: CGFloat = 36
    let margin: CGFloat = 12

    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(closePopupTapped(_:)), for: .touchUpInside)

    button.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
    button.tintColor = UIColor.label
    button.layer.cornerRadius = size / 2
    button.layer.borderWidth = 0.5
    button.layer.borderColor = UIColor.separator.cgColor

    if let img = UIImage(systemName: "xmark.circle.fill") {
      let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
      button.setImage(img.withConfiguration(cfg), for: .normal)
    }

    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowRadius = 4
    button.layer.shadowOpacity = 0.25

    container.addSubview(button)
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalTo: container.topAnchor, constant: margin),
      button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -margin),
      button.widthAnchor.constraint(equalToConstant: size),
      button.heightAnchor.constraint(equalToConstant: size)
    ])

    container.bringSubviewToFront(button)
    self.closeButton = button
  }

  @objc private func closePopupTapped(_ sender: UIButton) {
    if let popup = popupWebViews.last {
      webViewDidClose(popup)
    }
  }
}
