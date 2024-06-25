//
//  ServerURLController.m
//  MAGE
//
//  Created by William Newman on 11/16/15.
//  Copyright © 2015 National Geospatial Intelligence Agency. All rights reserved.
//

import CoreGraphics
import UIKit

@objc public protocol ServerURLDelegate {
    @objc func setServerURL(url: URL)
    @objc func cancelSetServerURL()
}

class ServerURLController: UIViewController {
    var didSetupConstraints = false
    @objc public var delegate: ServerURLDelegate?
    var scheme: MDCContainerScheming?
    var error: String?
    var additionalErrorInfo: Dictionary<String, Any>?
    
    lazy var progressView: MDCProgressView = {
        let progressView = MDCProgressView(forAutoLayout: ())
        progressView.mode = MDCProgressViewMode.indeterminate
        progressView.isHidden = true
        return progressView
    }()
    
    private lazy var serverURL: MDCFilledTextField = {
        let serverURL = MDCFilledTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 100));
        serverURL.autocapitalizationType = .none;
        serverURL.accessibilityLabel = "MAGE Server URL";
        serverURL.label.text = "MAGE Server URL"
        serverURL.placeholder = "MAGE Server URL"
        let worldImage = UIImageView(image: UIImage(systemName: "globe.americas.fill")?.aspectResize(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate))
        serverURL.leadingView = worldImage
        serverURL.leadingViewMode = .always
        serverURL.autocorrectionType = .no
        serverURL.autocapitalizationType = .none
        serverURL.keyboardType = .URL
        serverURL.delegate = self
        serverURL.sizeToFit();
        return serverURL;
    }()
    
    lazy var setServerUrlTitle: UITextView = {
        let setServerUrlTitle = UITextView(forAutoLayout: ())
        setServerUrlTitle.textAlignment = .center
        setServerUrlTitle.isSelectable = false
        setServerUrlTitle.backgroundColor = .clear
        setServerUrlTitle.text = "Set MAGE Server URL"
        return setServerUrlTitle
    }()
    
    lazy var wandMageContainer: UIView = {
        let container = UIView(forAutoLayout: ())
        container.clipsToBounds = false
        container.addSubview(wandLabel)
        container.addSubview(mageLabel)
        container.addSubview(callToActionLabel)
        return container
    }()
    
    lazy var wandLabel: UILabel = {
        let wandLabel = UILabel(forAutoLayout: ());
        wandLabel.numberOfLines = 0;
        wandLabel.font = UIFont(name: "FontAwesome", size: 64)
        wandLabel.text = "\u{0000f0d0}"
        wandLabel.textAlignment = .center
        wandLabel.baselineAdjustment = .alignBaselines
        return wandLabel;
    }()
    
    lazy var mageLabel: UILabel = {
        let mageLabel = UILabel(forAutoLayout: ());
        mageLabel.numberOfLines = 0;
        mageLabel.font = UIFont(name: "Roboto Light", size: 36)
        mageLabel.text = "Welcome to MAGE!"
        mageLabel.textAlignment = .center
        mageLabel.baselineAdjustment = .alignBaselines
        return mageLabel;
    }()
    
    lazy var callToActionLabel: UILabel = {
        let callToActionLabel = UILabel(forAutoLayout: ());
        callToActionLabel.numberOfLines = 0;
        callToActionLabel.font = UIFont(name: "Roboto", size: 14)
        callToActionLabel.text = "Specify a MAGE server URL to get started"
        callToActionLabel.textAlignment = .center
        callToActionLabel.baselineAdjustment = .alignBaselines
        return callToActionLabel;
    }()
    
    lazy var errorImage: UIImageView = {
        let errorImage = UIImageView(image: UIImage(systemName: "exclamationmark.circle.fill"))
        errorImage.isHidden = true
        return errorImage
    }()
    
    private lazy var buttonStack: UIStackView = {
        let buttonStack = UIStackView(forAutoLayout: ())
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        buttonStack.isLayoutMarginsRelativeArrangement = false;
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(okButton)
        return buttonStack;
    }()
    
    private lazy var cancelButton: MDCButton = {
        let cancelButton = MDCButton(forAutoLayout: ());
        cancelButton.accessibilityLabel = "Cancel";
        cancelButton.setTitle("Cancel", for: .normal);
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside);
        cancelButton.clipsToBounds = true;
        return cancelButton;
    }()
    private lazy var okButton: MDCButton = {
        let okButton = MDCButton(forAutoLayout: ());
        okButton.accessibilityLabel = "OK";
        okButton.setTitle("OK", for: .normal);
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside);
        okButton.clipsToBounds = true;
        return okButton;
    }()
    
    lazy var errorStatus: UITextView = {
        let errorStatus = UITextView(forAutoLayout: ())
        errorStatus.font = UIFont(name: "Roboto", size: 14)
        errorStatus.accessibilityLabel = "Server URL Error"
        errorStatus.textAlignment = .center
        errorStatus.isSelectable = true
        errorStatus.backgroundColor = .clear
        errorStatus.isHidden = true

        return errorStatus
    }()
    
    lazy var errorInfoLink: UILabel = {
        let errorInfoLink = UILabel(forAutoLayout: ())
        errorInfoLink.textAlignment = .center
        errorInfoLink.backgroundColor = .clear
        errorInfoLink.font = UIFont(name: "Roboto", size: 12)
        errorInfoLink.text = "more info"
        errorInfoLink.isHidden = true
        errorInfoLink.isUserInteractionEnabled = true
        errorInfoLink.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(errorInfoLinkTapped)))
        return errorInfoLink
    }()
    
     
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical;
        stackView.distribution = .fillEqually;
        stackView.alignment = .fill;
        stackView.spacing = 30
        return stackView
    }()
    
    lazy var headerSectionView: UIView = {
        let headerSectionView = UIView(forAutoLayout: ())
        return headerSectionView
    }()
    
    lazy var inputSectionView: UIView = {
        let inputSectionView = UIView(forAutoLayout: ())
        return inputSectionView
    }()
    
    lazy var footerSectionView: UIView = {
        let footerSectionView = UIView(forAutoLayout: ())
        return footerSectionView
    }()
    

    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc convenience public init(delegate: ServerURLDelegate, error: String? = nil, scheme: MDCContainerScheming?) {
        self.init(frame: CGRect.zero)
        self.scheme = scheme
        self.delegate = delegate
        self.error = error
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    @objc public func applyTheme(withContainerScheme containerScheme: MDCContainerScheming?) {
        guard let scheme = containerScheme else {
            return
        }
        self.scheme = scheme
        self.view.backgroundColor = scheme.colorScheme.backgroundColor
        self.setServerUrlTitle.textColor = scheme.colorScheme.primaryColorVariant
        self.setServerUrlTitle.font = scheme.typographyScheme.headline6
        self.wandLabel.textColor = scheme.colorScheme.primaryColorVariant
        self.mageLabel.textColor = scheme.colorScheme.onSurfaceColor
        self.callToActionLabel.textColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6)
        errorStatus.textColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6)
        okButton.applyContainedTheme(withScheme: scheme)
        cancelButton.applyContainedTheme(withScheme: scheme)
        serverURL.applyTheme(withScheme: scheme)
        serverURL.leadingView?.tintColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6)
        errorImage.tintColor = scheme.colorScheme.errorColor
        errorInfoLink.textColor = scheme.colorScheme.primaryColorVariant
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad();

        headerSectionView.addSubview(wandMageContainer)
        stackView.addArrangedSubview(headerSectionView)
                
        inputSectionView.addSubview(serverURL)
        inputSectionView.addSubview(buttonStack)
        inputSectionView.addSubview(progressView)
        stackView.addArrangedSubview(inputSectionView)
        
        footerSectionView.addSubview(errorImage)
        footerSectionView.addSubview(errorStatus)
        footerSectionView.addSubview(errorInfoLink)
        stackView.addArrangedSubview(footerSectionView)
        
        view.addSubview(stackView)
        applyTheme(withContainerScheme: scheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = MageServer.baseURL()
        
        if let error = error {
            showError(error: error)
            cancelButton.isEnabled = false
            cancelButton.isHidden = true
            serverURL.text = url?.absoluteString
        } else if let scheme = scheme {
            serverURL.applyTheme(withScheme: scheme)
        }
        
        if let url = url {
            serverURL.text = url.absoluteString
        } else {
            cancelButton.isEnabled = false
            cancelButton.isHidden = true
        }
    }
    
    @objc public func showError(error: String, userInfo:Dictionary<String, Any>? = nil) {
        errorStatus.isHidden = false
        errorInfoLink.isHidden = false
        errorImage.isHidden = false
        progressView.isHidden = true
        progressView.stopAnimating()
        errorStatus.text = "This URL does not appear to be a MAGE server."
        additionalErrorInfo = userInfo
        if let scheme = scheme {
            serverURL.applyErrorTheme(withScheme: scheme)
        }
    }

    public override func updateViewConstraints() {
        if (!didSetupConstraints) {
            
            wandLabel.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            
            mageLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
            mageLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
            mageLabel.autoPinEdge(.top, to: .bottom, of: wandLabel, withOffset: 16)

            callToActionLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
            callToActionLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
            callToActionLabel.autoPinEdge(.top, to: .bottom, of: mageLabel, withOffset: 8)
            
            wandMageContainer.autoPinEdge(toSuperviewSafeArea: .top, withInset: 24)
            wandMageContainer.autoAlignAxis(toSuperviewAxis: .vertical)
            
            serverURL.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
            serverURL.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            serverURL.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            buttonStack.autoPinEdge(.top, to: .bottom, of: serverURL, withOffset: 8)
            buttonStack.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            buttonStack.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            progressView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
            progressView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
            progressView.autoSetDimension(.height, toSize: 5)
            progressView.autoPinEdge(.top, to: .bottom, of: serverURL)
            
            errorImage.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            errorImage.autoSetDimensions(to: CGSize(width: 24, height: 24))
            errorImage.autoAlignAxis(toSuperviewAxis: .vertical)

            errorStatus.autoPinEdge(toSuperviewMargin: .left, withInset: 16)
            errorStatus.autoPinEdge(toSuperviewMargin: .right, withInset: 16)
            errorStatus.autoPinEdge(toSuperviewMargin: .top, withInset: 40)
            errorStatus.autoSetDimension(.height, toSize: 32)
            
            errorInfoLink.autoPinEdge(toSuperviewMargin: .left, withInset: 16)
            errorInfoLink.autoPinEdge(toSuperviewMargin: .right, withInset: 16)
            errorInfoLink.autoPinEdge(.top, to: .bottom, of: errorStatus, withOffset: 10)
            errorInfoLink.autoSetDimension(.height, toSize: 16)
                        
            stackView.autoPinEdgesToSuperviewSafeArea()
            didSetupConstraints = true;
        }
        
        super.updateViewConstraints();
    }
    
    @objc func okTapped() {
        
        guard let urlString = serverURL.text else {
            showError(error: "Invalid URL")
            return
        }
        
        guard var urlComponents = URLComponents(string: urlString) else {
            showError(error: "Invalid URL")
            return
        }
        
        // Handle cases without path or scheme, e.g. "magedev.geointnext.com"
        if urlComponents.path != "" && urlComponents.host == nil {
            urlComponents.host = urlComponents.path
            urlComponents.path = ""
        }
        
        // Remove trailing "/" in the path if they entered one by accident
        if urlComponents.path == "/" {
            urlComponents.path = ""
        }
        
        // Supply a default HTTPS scheme if none is specified
        if urlComponents.scheme == nil {
            urlComponents.scheme = "https"
        }
        
        if let url = urlComponents.url {
            errorStatus.isHidden = true
            errorInfoLink.isHidden = true
            errorImage.isHidden = true
            progressView.isHidden = false
            progressView.startAnimating()
            delegate?.setServerURL(url: url)
            if let scheme = scheme {
                serverURL.applyTheme(withScheme: scheme)
            }

        } else {
            showError(error: "Invalid URL")
        }
    }
    
    @objc func cancelTapped() {
        delegate?.cancelSetServerURL()
    }

    @objc func errorInfoLinkTapped() {
        
        var errorTitle = "Error"
        var errorMessage = "Failed to connect to server."
        
        if let additionalErrorInfo = additionalErrorInfo {
            if let statusCode = additionalErrorInfo["statusCode"] as? Int {
                errorTitle = String(statusCode)
            }
            if let desc = additionalErrorInfo["NSLocalizedDescription"] as? String {
                errorMessage = desc
            }
        }
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

extension ServerURLController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        okTapped()
        return true
    }
}
