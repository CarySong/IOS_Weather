//
//创建httpTool 实例
//let TabHttpTool = httpTool.sharedTools
////创建请求参数
//let params = ["username":"invest","password":"123456"]
////发送psot请求
//TabHttpTool.request(RequsetMethod.POST, urlString: "http://api....../login", parameters: params) { (response, error) in
// if (error != nil)
//{
//print(response)
//}
//?
//
import UIKit
import AFNetworking
//请求方法
/// - GET:  get
/// - POST: post
enum RequsetMethod:String {
    case GET = "GET"
    case POST =  "POST"
}

class httpTool: AFHTTPSessionManager {
    
    //单例
    static let sharedTools:httpTool = {
            let instance = httpTool()
//            instance.responseSerializer.acceptableContentTypes?.insert("text/html")
//            instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
            instance.responseSerializer = AFHTTPResponseSerializer()
            return instance
    }()
    // 定义请求完成的回调的别名
    typealias httptoolBack = (_ response:Any?, _ error: Error?)->()
    
    /// 请求数据
    ///
    /// - parameter urlString:  请求地址
    /// - parameter parameters: 请求参数
    /// - parameter finished:   请求成功或者失败的回调
    
    func request(method: RequsetMethod = .GET, urlString: String, parameters: AnyObject?, finished:@escaping httptoolBack){
        
        // 定义请求成功的闭包
        let success = { (dataTask: URLSessionDataTask, responseObject: Any?) -> Void in
            finished(responseObject, nil)
        }
        
        // 定义请求失败的闭包
        let failure = { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            finished(nil, error)
        }
        
       
        if method == .GET {
            get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }else{
            post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
       
    }


    
    
    /// 发送请求(上传文件)
    
    func requestWithData(data: Data, name: String, urlString: String, parameters: AnyObject?, finished:@escaping httptoolBack) {
        // 定义请求成功的闭包
        let success = { (dataTask: URLSessionDataTask, responseObject: Any?) -> Void in
            finished(responseObject, nil)
        }
        
        // 定义请求失败的闭包
        let failure = { (dataTask: URLSessionDataTask?, error: Error) -> Void in
            finished(nil, error)
        }
        
        post(urlString, parameters: parameters, constructingBodyWith: { (formData) -> Void in
            formData.appendPart(withFileData: data, name: name, fileName:"", mimeType: "application/octet-stream")
        }, progress: nil, success: success, failure: failure)
    }
}
