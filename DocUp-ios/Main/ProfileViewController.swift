import UIKit
import BLTNBoard
import CircleProgressBar

class ProfileViewController: UIViewController, URLSessionDelegate {

    var timer: Timer?
    
    private lazy var boardManager:BLTNItemManager={
        let item = BLTNPageItem(title: "SOS")
        item.actionButtonTitle="SOS"
        item.alternativeButtonTitle="Cancel"
        item.appearance.actionButtonColor = UIColor.systemRed
        item.appearance.alternativeButtonTitleColor=UIColor.gray
        item.alternativeHandler={(item: BLTNActionItem) in self.closeWindow()}
        item.actionHandler={(item: BLTNActionItem) in
            var url:URL=URL(string: "tel://"+self.responseProfile.doctorPhoneNumber)!
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in })
            self.closeWindow()}
        return BLTNItemManager(rootItem: item)
    }()
    
    
    @IBOutlet weak var ProgressBar: UIProgressView!
    @IBOutlet weak var PatientInfo: UIView!
    @IBOutlet weak var DoctorInfo: UIView!
    @IBOutlet weak var WatcherInfo: UIView!
    @IBOutlet weak var IllnessInfo: UIView!
    @IBOutlet weak var SosButton: UIButton!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var PhoneNumber: UILabel!
    @IBOutlet weak var DoctorName: UILabel!
    @IBOutlet weak var DoctorPhoneNumber: UILabel!
    @IBOutlet weak var WatcherName: UILabel!
    @IBOutlet weak var WatcherPhoneNumber: UILabel!
    @IBOutlet weak var Percent: UILabel!
    @IBOutlet weak var IllnessName: UILabel!
    @IBOutlet weak var Login: UILabel!
    
    var token:String!
    var responseProfile:ResponseProfile!
    
    override func viewDidLoad() {
        print("📘","PROCESSING: ProfileViewController initialization...")
        super.viewDidLoad()
        
        
        self.SosButton.layer.cornerRadius=10
        self.SosButton.layer.masksToBounds=true
        
        self.PatientInfo.layer.cornerRadius=10
        self.PatientInfo.layer.masksToBounds=true
        
        self.DoctorInfo.layer.cornerRadius=10
        self.DoctorInfo.layer.masksToBounds=true
        
        self.WatcherInfo.layer.cornerRadius=10
        self.WatcherInfo.layer.masksToBounds=true
        
        self.IllnessInfo.layer.cornerRadius=10
        self.IllnessInfo.layer.masksToBounds=true
        
        self.ProgressBar.transform = self.ProgressBar.transform.scaledBy(x: 1, y: 3)
        self.ProgressBar.layer.cornerRadius=10
        self.ProgressBar.layer.masksToBounds=true
        
        getData()
        getIllnessesRequest()
        self.navigationItem.hidesBackButton=true
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getIllnesses), userInfo: nil, repeats: true)
        print("📗","SUCCESS: ProfileViewController initialized")
    }
    
    @IBAction func Logout(_ sender: Any) {
        let LoginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(LoginPage, animated: true)
    }
    
    @IBAction func Sos(_ sender: Any) {
        boardManager.backgroundViewStyle = .blurredDark
        boardManager.showBulletin(above: self)
    }
    
    func closeWindow(){
        boardManager.dismissBulletin()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func getData(){
        print("📘","PROCESSING: Preparing the request...")
        let path = API.GetProfile
        print("📙","INFO: Path: "+path)
        guard let url = URL(string: path) else {return}
        var request = URLRequest(url:url)
        request.httpMethod="GET"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization")
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
            if(response.statusCode==200){
                let decoder = JSONDecoder()
                do {
                    let user = try decoder.decode(ResponseProfile.self, from: data)
                    self.responseProfile=user
                    self.Login.text=user.login
                    self.NameLabel.text=user.name+" "+user.surname+" "+String(user.age)+" y.o."
                    self.Address.text=user.address
                    self.PhoneNumber.text = user.phoneNumber
                    self.DoctorName.text = user.doctorName+" "+user.doctorSurname
                    self.DoctorPhoneNumber.text=user.doctorPhoneNumber
                    self.WatcherName.text=user.watcherName+" "+user.watcherSurname
                    self.WatcherPhoneNumber.text=user.watcherPhoneNumber
                    self.Email.text=user.email
                    print("📗","SUCCESS: Success get profile")
                } catch {
                    print(error.localizedDescription)
                }
            }
            else{
                print("📕","ERROR: Unknown status code")
                let LoginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(LoginPage, animated: true)
            }
        }.resume()
    }
    
    @objc func getIllnesses(){
        getIllnessesRequest()
    }
    
    func getIllnessesRequest(){
        print("📘","PROCESSING: Preparing the request...")
        let path = API.GetIllnesses
        print("📙","INFO: Path: "+path)
        guard let url = URL(string: path) else {return}
        var request = URLRequest(url:url)
        request.httpMethod="GET"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "content-type")
        request.addValue("Bearer "+token, forHTTPHeaderField: "Authorization")
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
            if(response.statusCode==200){
                let decoder = JSONDecoder()
                do {
                    let illnesses = try decoder.decode([Illness].self, from: data)
                    var max=0
                    for i in 0...illnesses.count-1{
                        if(Int(illnesses[i].percent)!>max){
                            max = Int(illnesses[i].percent)!
                        }
                    }
                    for i in 0...illnesses.count-1{
                        if(Int(illnesses[i].percent)!==max){
                            self.Percent.text=String(illnesses[i].percent+" %")
                            self.IllnessName.text=String(illnesses[i].illness)
                            self.ProgressBar.progress = Float(illnesses[i].percent)!/100.0
                            self.ProgressBar.tintColor = self.mixGreenAndRed(greenAmount: 1.0 - Float(illnesses[i].percent)!/100.0)
                            self.Percent.textColor = self.mixGreenAndRed(greenAmount: 1.0 - Float(illnesses[i].percent)!/100.0)
                        }
                    }
                    print("📗","SUCCESS: Success get illnesses")
                } catch {
                    print(error.localizedDescription)
                }
            }
            else{
                print("📕","ERROR: Unknown status code")
                let LoginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(LoginPage, animated: true)    
            }
        }.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func mixGreenAndRed(greenAmount: Float) -> UIColor {
        return UIColor(red: CGFloat((1.0 - greenAmount)), green: CGFloat(greenAmount), blue: CGFloat(0.0), alpha: 1.0)
    }
    
}

struct ResponseProfile: Codable {
    var login: String
    var email: String
    var name: String
    var surname: String
    var phoneNumber: String
    var address: String
    var watcherName: String
    var watcherSurname: String
    var watcherPhoneNumber: String
    var doctorName: String
    var doctorSurname: String
    var doctorPhoneNumber: String
    var clinicName: String
    var clinicPhoneNumber: String
    var age: Int
}

struct Illness: Codable {
    var illness: String
    var percent: String
}

