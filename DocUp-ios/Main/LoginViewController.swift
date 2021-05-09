import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate,URLSessionDelegate {
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    
    override func viewDidLoad() {
        print("📘","PROCESSING: LoginViewController initialization...")
        super.viewDidLoad()

        self.PasswordTextField.delegate = self
        self.LoginTextField.delegate = self
        
        self.navigationItem.hidesBackButton=true
        
        self.ErrorLabel.isHidden=true
        self.ErrorLabel.layer.cornerRadius=10
        self.ErrorLabel.layer.masksToBounds=true
        
        self.SendButton.layer.cornerRadius=10
        
        self.LoginTextField.layer.borderColor=UIColor.lightGray.cgColor
        self.LoginTextField.layer.borderWidth=1.0
        self.LoginTextField.layer.cornerRadius=5
        self.LoginTextField.layer.masksToBounds=true
        
        self.PasswordTextField.layer.borderColor=UIColor.lightGray.cgColor
        self.PasswordTextField.layer.borderWidth=1.0
        self.PasswordTextField.layer.cornerRadius=5
        self.PasswordTextField.layer.masksToBounds=true
        print("📗","SUCCESS: LoginViewController initialized")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    @IBAction func loginChanged(_ sender: Any) {
        self.ErrorLabel.isHidden=true
        self.PasswordTextField.layer.borderColor=UIColor.lightGray.cgColor
        self.LoginTextField.layer.borderColor=UIColor.lightGray.cgColor
        print("📙","INFO: Login changed: "+self.LoginTextField.text!)
    }
    @IBAction func passwordChanged(_ sender: Any) {
        self.ErrorLabel.isHidden=true
        self.PasswordTextField.layer.borderColor=UIColor.lightGray.cgColor
        self.LoginTextField.layer.borderColor=UIColor.lightGray.cgColor
        print("📙","INFO: Password changed: "+self.PasswordTextField.text!)
    }
    
    @IBAction func SendButtonClick(_ sender: Any) {
        print("📘","PROCESSING: Login button was clicked...")
        let login = LoginTextField.text!
        let password = PasswordTextField.text!
        let isValid = validation(login:login, password:password)
        if (isValid){
            sendData(login: login, password: password)
        }
    }
    
    func validation(login: String, password: String) -> Bool {
        print("📘","PROCESSING: Validation started...")
        if(login.count<5 && password.count<5){
            self.ErrorLabel.text="Login and password must be longer than 5 characters!"
            self.ErrorLabel.isHidden=false
            self.LoginTextField.layer.borderColor=UIColor.red.cgColor
            self.PasswordTextField.layer.borderColor=UIColor.red.cgColor
            print("📕","ERROR: Login and password are invalid")
            return false
        }
        if(login.count<5){
            self.ErrorLabel.text="Login must be longer than 5 characters!"
            self.ErrorLabel.isHidden=false
            self.LoginTextField.layer.borderColor=UIColor.red.cgColor
            print("📕","ERROR: Login is invalid")
            return false
        }
        if(password.count<5){
            self.ErrorLabel.text="Password must be longer than 5 characters!"
            self.ErrorLabel.isHidden=false
            self.PasswordTextField.layer.borderColor=UIColor.red.cgColor
            print("📕","ERROR: Password is invalid")
            return false
        }
        print("📗","SUCCESS: Data is valid")
        return true
    }
    
    func sendData(login: String, password: String){
        print("📘","PROCESSING: Preparing the request...")
        let path = "https://192.168.1.4:5001/api/v1/auth/login"
        print("📙","INFO: Path: "+path)
        guard let url = URL(string: path) else {return}
        let parameters = ["login":login, "password":password]
        var request = URLRequest(url:url)
        request.httpMethod="POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
        print("📙","INFO: Http body: "+String(data: httpBody, encoding: .utf8)!)
        request.httpBody=httpBody
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        session.dataTask(with: request) { data, response, error in
            print("📘","PROCESSING: Sending the request...")
            guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {
                    print("📕","ERROR: "+error!.localizedDescription)
                    return
                }
            let responseString = String(data: data, encoding: .utf8)
            print("📙","INFO: Status code: "+String(response.statusCode))
            print("📙","INFO: Response body: "+responseString!)
            if(response.statusCode==409){
                let code = Int(responseString!)
                let message = self.errorMapper(code: code!)
                self.ErrorLabel.text=message
                self.ErrorLabel.isHidden=false
                print("📕","ERROR: Conflict: "+message)
            }
            else if(response.statusCode==200){
                let decoder = JSONDecoder()
                do {
                    let user = try decoder.decode(Response.self, from: data)
                    print("📙","INFO: Login: "+user.login)
                    print("📙","INFO: Role: "+user.role)
                    print("📙","INFO: Token: "+user.token)
                    if(user.role != "patient"){
                        self.ErrorLabel.text="Your account is not patient!"
                        self.ErrorLabel.isHidden=false
                        print("📕","ERROR: User is not patient!")
                        return
                    }
                    let ProfilePage = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    ProfilePage.token = user.token
                    self.navigationController?.pushViewController(ProfilePage, animated: true)
                    print("📗","SUCCESS: Success login")
                } catch {
                    print(error.localizedDescription)
                }
            }
            else{
                self.ErrorLabel.text="Sorry, something went wrong, try it later!"
                self.ErrorLabel.isHidden=false
                print("📕","ERROR: Unknown status code")
            }
        }.resume()
    }
    
    func errorMapper(code:Int)->String{
        if(code==11){return "Invalid login!"}
        if(code==12){return "Invalid password!"}
        return "Unknown error!"
    }
}

struct Response: Codable {
    var token: String
    var login: String
    var role: String
}
