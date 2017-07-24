//
//

import UIKit
import AFNetworking

let getSupportProvince = "http://www.webxml.com.cn/WebServices/WeatherWebService.asmx/getSupportProvince"
class ProvincesViewController: UITableViewController {
    
    weak var rootViewController: AnyObject!
    var provinces = [String]()
     override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择省份"
        // 通过webService获取省份信息
    
//        func request(method: RequsetMethod = .GET, urlString: String, parameters: AnyObject?, finished:@escaping httptoolBack){}
//         典型的尾随闭包
        httpTool.sharedTools.request(method: .GET, urlString: getSupportProvince, parameters: nil) { (response, error) in
            let str = NSString(data:response as! Data, encoding:String.Encoding.utf8.rawValue)! as String!
            
            print(str!)

     
        
           
        // 调用 synchronousRequest方法根据城市名称获取城市的天气信息,
        // 返回的是一个xml格式的字符串
//        manager.get(getSupportProvince, parameters: nil, progress: nil,
//                    success: {[unowned self] task, responseObject in
//                
//                        let responseString = NSString(data: (responseObject as! NSData) as Data, encoding:String.Encoding.utf8.rawValue)! as String?
//                       // print(responseString)
//                        if responseString != nil {
//
//                            let doc = try! DDXMLDocument(xmlString:responseString!, options:1)
//                            // 获取根节点对象
//                            let rootElement = doc.rootElement()
//                            // 获取所有<string.../>子元素，返回数组集合
//                            let provinceElements = rootElement?.elements(forName: "string")
//                            // 循环遍历每一个<string.../>子元素
//                            for provinceElement in provinceElements! {
//                                // 将每个省份添加到数组
//                                self.provinces.append((provinceElement.stringValue)!)
//                            }
//                            self.tableView.reloadData()
//                        }
//                    },
//                    failure: {task, error in
//                        print("获取服务器数出错!\(error)")
//        })
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return provinces.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        // 获取可重用的单元格
        let cell = tableView.dequeueReusableCell(withIdentifier: "provinceCell",for:indexPath)
        // 根据行号来获取省份
        let rowString = provinces[indexPath.row]
        // 为每个单元格设置省份
        cell.textLabel!.text = rowString
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        let dest = segue.destination as! CitiesViewController
        // 获取激发segue的单元格
        let clickedCell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: clickedCell)
        // 根据激发segue的行获得数组中对应的省份
        let province = provinces[indexPath!.row]
        dest.province = province
        dest.delegate = self.rootViewController as! CitiesViewControllerDelegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
