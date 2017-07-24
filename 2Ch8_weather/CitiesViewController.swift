//
//  CitiesViewController.swift
//  Weather
//
//  Created by yeeku on 16/2/19.
//  Copyright © 2016年 org.crazyit. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol CitiesViewControllerDelegate{
    func addCityToRootView(_ cityValue: String)
}
let getSupportCity = "http://www.webxml.com.cn/WebServices/WeatherWebService.asmx/getSupportCity"
class CitiesViewController: UITableViewController {
    var province: String!
    var cities = [String]()
    var manager : AFHTTPSessionManager!
    
    weak var delegate: CitiesViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择城市"
        // 通过webService获取城市信息
        manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()

        let params: NSDictionary = ["byProvinceName" : self.province]
        
        manager.get(getSupportCity, parameters: params, progress: nil,
                    success: {[unowned self] task, responseObject in
                        
                        let responseString = NSString(data: (responseObject as! NSData) as Data, encoding:String.Encoding.utf8.rawValue)! as String?
                        print(responseString!)
                        
                        if responseString != nil {
                            // 根据NSString对象初始化DDXMLDocument对象
                            let doc = try! DDXMLDocument(xmlString:responseString!, options:1)
                            // 获取根节点对象
                            let rootElement = doc.rootElement()
                            // 获取<string.../>子元素，返回数组对象
                            let cityElements = rootElement?.elements(forName: "string")
                            // 循环遍历每一个<string.../>元素，每个元素的内容为：广州(编号)的形式，
                            // 因此要去掉后面的括号部分
                            for cityElement in cityElements! {
                                // 获取"("出现的范围
                                let range = (cityElement as AnyObject).stringValue.range(of: "(")
                                // 获取"("前面的内容，也就是只获取城市的名称
                                let city = (cityElement as AnyObject).stringValue.substring(to: (range?.lowerBound)!)
                                self.cities.append(city)
                            }
                            self.tableView.reloadData()
                        }
                    },
                    failure: {task, error in
                        print("获取服务器数出错!\(error)")
                            }
                )
           }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        return cities.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 获取可重用的单元格
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell",for:indexPath)
        // 根据行号来获取城市
        let rowString = cities[indexPath.row]
        // 为每个单元格设置城市
        cell.textLabel!.text = rowString
        return cell
    }
    // 当用户选择某个城市时激发该方法
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        // 获取用户选择的城市
        let city = cities[indexPath.row]
        // 调用delegate对象的方法，从而将用户选择的城市传给delegate对象
        self.delegate.addCityToRootView(city)
        // 返回根视图控制器
        if (self.navigationController != nil)
        {
        self.navigationController!.popToRootViewController(animated: true)
        }
        else
        {
        print("navi is nil")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
