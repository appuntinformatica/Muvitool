import UIKit
import XCGLogger
import SwiftValidator
import DownPicker

extension UITextView: Validatable {
    public var validationText: String {
        return text ?? ""
    }
}

class ContactViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    let log = XCGLogger.default
    
    let textHeight = 30
    let validator = Validator()

    var progressIndicator:     UIActivityIndicatorView!
    
    var descriptionLabel:      UILabel!
    var descriptionErrorLabel: UILabel!
    var descriptionTextView:   UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = Strings.Contact
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.Send, style: .plain, target: self, action: #selector(sendMailAction))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        // Do any additional setup after loading the view.
        
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.text = Strings.Description
        self.view.addSubview(self.descriptionLabel)
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(75)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.descriptionErrorLabel = UILabel()
        self.descriptionErrorLabel.textColor = .red
        self.descriptionErrorLabel.textAlignment = .right
        self.view.addSubview(self.descriptionErrorLabel)
        self.descriptionErrorLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(75)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.descriptionTextView = UITextView()
        self.descriptionTextView.backgroundColor = .white
        self.view.addSubview(self.descriptionTextView)
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.descriptionLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-10)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            self.log.info("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
                
            }
        }, error:{ (validationError) -> Void in
            self.log.info("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        })
        
        self.progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.progressIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.view.addSubview(self.progressIndicator)
        self.progressIndicator.snp.makeConstraints {
            $0.center.equalTo(self.view.snp.center)
        }
        
        let rr = RequiredRule(message: Strings.FieldIsRequired)
        validator.registerField(descriptionTextView, errorLabel: descriptionErrorLabel, rules: [rr])
    }
    
    func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMailAction(_ sender: UIBarButtonItem) {
        self.log.info("Validating...")
        validator.validate(self)
    }
    
    func validationSuccessful() {
        self.log.info("Validation Success!")
        sendMail()
    }
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        self.log.info("Validation FAILED!")
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: Validate single field
    // Don't forget to use UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField){ error in
            if error == nil {
                // Field validation was successful
            } else {
                // Validation error occurred
            }
        }
        return true
    }
    
    func sendMail() {
        self.view.subviews.forEach { $0.isUserInteractionEnabled = false }
        self.progressIndicator.startAnimating()
        
        let session = MCOSMTPSession()
        session.hostname = "smtp.gmail.com"
        session.port = 465
        session.username = "username"
        session.password = "password"
        session.connectionType = .TLS
        session.authType = [.saslPlain, .saslLogin, .xoAuth2]
        session.connectionLogger = { (connectionID, type, data) in
            if data != nil, let string = String(data: data!, encoding: String.Encoding.utf8) {
                self.log.info(string)
            }
        }
        let builder = MCOMessageBuilder()
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let displayName = "\(appName)"
        builder.header.from = MCOAddress(displayName: displayName, mailbox: "source@domain.com")
        builder.header.to = [MCOAddress(displayName: displayName, mailbox: "dest@domain.com")]
        builder.header.subject = "\(displayName) \(Date())"
        let description = self.descriptionTextView.text.convertHtmlSymbols()
        self.log.info(description)
        
        builder.htmlBody = "\(description)"
        
        let rfc822Data = builder.data()
        if let sendOperation = session.sendOperation(with: rfc822Data) {
            sendOperation.start { (error) -> Void in
                self.progressIndicator.stopAnimating()
                self.view.subviews.forEach { $0.isUserInteractionEnabled = true }
                var message = ""
                if error != nil {
                    message = Strings.ErrorSendingEmail                    
                    self.log.info("Error sending email: \(String(describing: error))")
                } else {
                    message = Strings.SuccessSendingEmail
                    self.log.info("Successfully sent email!")
                    
                }
                let ac = UIAlertController(title: "", message: message, preferredStyle: .alert)                
                let da = UIAlertAction(title: Strings.OK, style: .default, handler: { alertAction in
                    self.dismiss(animated: true, completion: nil)
                })
                ac.addAction(da)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}
