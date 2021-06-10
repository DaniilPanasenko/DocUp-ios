struct API{
    static let BaseAddress = "http://192.168.1.3:5000/"
    static let Login = BaseAddress+"api/v1/auth/login"
    static let GetProfile = BaseAddress+"api/v1/patient/info"
    static let GetIllnesses = BaseAddress+"api/v1/patient/illnesses"
}
