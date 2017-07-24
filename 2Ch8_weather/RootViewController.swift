//
//  RootViewController.swift
//  Weather
//
//  Created by yeeku on 16/2/19.
//  Copyright © 2016年 org.crazyit. All rights reserved.
//

import UIKit
import AFNetworking


let getWeatherbyCityName = "http://www.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName"
// 定义静态单元格原型的Identifier
let cellId = "weatherCell"

class RootViewController: UITableViewController, CitiesViewControllerDelegate {
    
    var manager: AFHTTPSessionManager!
    // 定义一个可变数的组集合，用于缓存当前系统需要显示天气的城市列表
    var cityData: [String]!
    // 定义一个可变的字典集合，用于缓存从服务器下载得到天气数据
    var weatherData: [String: String]!
    
    typealias  callBackType = (URLSessionDataTask, Any?) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "天气预报"
        // 如果保存城市列表的属性列表文件不存在
        if !FileManager.default.fileExists(atPath: self.filePath) {
            // 默认只显示广州的天气
            cityData = ["广州"]
        }else{
            // 如果保存城市列表的属性列表文件存在，直接显示该属性列表文件中的所有城市
            cityData = NSArray(contentsOfFile:self.filePath) as! [String]
        }
        // 创建weatherData集合，用于缓存已经从服务器下载的天气数据
        weatherData = [String: String]()
        self.tableView.isScrollEnabled = false  // 设置不可滚动
        // 自定义颜色
        let customColor = UIColor(red:48/255.0, green:67/255.0,
                                  blue:97/255.0, alpha:0.8)
        self.tableView.backgroundColor = customColor  // 设置自定义背景
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        
    }
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return cityData.count
    }
    // 该方法的返回值用于控制每个表格行的高度
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        // 获取可重用的单元格
        var cell = self.tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style:.default, reuseIdentifier:cellId)
            let tableWidth = tableView.bounds.size.width
            cell!.frame = CGRect(x: 0, y: 0, width: tableWidth, height: 75)
            // 创建和添加显示天气的图标
            let iv = UIImageView(frame:CGRect(x: tableWidth - 60, y: 5, width: 50, height: 46))
            iv.tag = 3
            cell!.addSubview(iv)
            // 采用循环创建、并添加2个UILabel控件
            for i in 0 ..< 2 {
                let labelWidth = (tableWidth - 60 - 10) / 2
                let label = UILabel(frame:CGRect(
                    x: 10 + labelWidth * CGFloat(i), y: 5, width: labelWidth, height: 30))
                label.font = UIFont.boldSystemFont(ofSize: 18)
                label.tag = i + 1
                cell!.addSubview(label)
            }
            // 创建一个显示天气详情的UILabel控件
            let label = UILabel(frame:CGRect(x: 10 , y: 35, width: tableWidth - 70, height: 35))
            label.font = UIFont.systemFont(ofSize: 13)
            label.tag = 4
            label.numberOfLines = -1
            cell!.addSubview(label)
            // 为单元格设置圆角边框
            cell!.layer.cornerRadius = 8
            cell!.layer.masksToBounds = true
        }
        // 根据当前行号获取对应的城市
        let city = cityData[indexPath.row]
               // 创建ASIHTTPRequestUtil的对象
        
        let params: NSDictionary = ["theCityName" : city]

        // 调用 synchronousRequest方法根据城市名称获取城市的天气信息,
        // 返回的是一个xml格式的字符串
     
//        NetworkManager.shared.request(requestType: .GET, urlString: getWeatherbyCityName, parameters: (params as? [String : String])!) { (json) in
//             let str = NSString(data:json as! Data, encoding:String.Encoding.utf8.rawValue)! as String!
//            print(str!)  }
      
        manager.get(getWeatherbyCityName, parameters: params, progress: nil,
                    success:{[unowned self] task, responseObject in
                       
                       let responseString = NSString(data:responseObject as! Data, encoding:String.Encoding.utf8.rawValue)! as String!

                        if  responseString != nil {
                            //print(responseString)
                            self.weatherData[city] = responseString
                            // 根据responseString获取一个XML Document
                            let doc = try! DDXMLDocument(xmlString: responseString!, options:1)
                            // 获取根节点对象
                            let rootElement = doc.rootElement()
                            // 获取<string.../>子元素，返回数组对象
                            let dataElements = rootElement?.elements(forName: "string")
                            // 获取显示城市名称的UILabel，并设置城市名。
                            let cityNameLabel = cell!.viewWithTag(1) as! UILabel
                            cityNameLabel.text = city
                            // 获取显示气温的UILabel，并设置气温。
                            let tempLabel = cell!.viewWithTag(2) as! UILabel
                            tempLabel.text = (dataElements?[5] as AnyObject).stringValue
                            // 获取显示天气图标的UIImageView，并设置显示图片
                            let weatherIv = cell!.viewWithTag(3) as! UIImageView
                            weatherIv.image = UIImage(named:"legend/b_\((dataElements?[8] as AnyObject).stringValue!)")
                            // 索引为10的<string.../>的内容如下：
                            // 今日天气实况：气温：12℃；风向/风力：西南风 1级；湿度：92%；紫外线强度：最弱。空气质量：良。
                            // 使用substringFromIndex:7去掉前面的“今日天气实况：”部分。
                            let str = (dataElements?[10] as AnyObject).stringValue!
                            let detailLabel = cell!.viewWithTag(4) as! UILabel

                            if (str.characters.count > 7) {
                              let content = str.substring(from: str.index(str.startIndex, offsetBy: 7))
                                detailLabel.text = content
                            }
                            else {
                             
                                detailLabel.text = str
                            }
                            
                        }
            },
                    failure: {task, error in
                            print("获取服务器数出错!\(error)")
        })

        // 从远程服务器获取数据 ，免费用户二次获取数据时间要超过600ms，所以此处暂停0.7秒
        Thread.sleep(forTimeInterval: 0.7)
        
        return cell!
    }
    
    let callback: callBackType = { (task: URLSessionDataTask, json: Any) -> Void in
        let responseString = NSString(data: json as! Data, encoding:String.Encoding.utf8.rawValue)! as String!
        
        print (responseString!)
        
    }
    
    func cback (task: URLSessionDataTask, json: Any) -> Void
    {
        let responseString = NSString(data: json as! Data, encoding:String.Encoding.utf8.rawValue)! as String!
        
        print (responseString!)
    }
   
    // 当用户选择某个城市时激发该方法
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        let destController = self.storyboard!
            .instantiateViewController(withIdentifier: "forecastScene")
            as! ForecastViewController
        // 将用户选择的城市的天气情况传给下一个视图控制器。
        destController.weatherString = weatherData[cityData[indexPath.row]]  // ①
        self.navigationController?.pushViewController(destController,
                                                      animated: true)
    }
    // 当用户点击“添加城市”按钮时触发segue时调用该方法
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 获取该segue导航的目标视图控制器
        let destController = segue.destination
        // 将当前根视图控制器传给对象传给ProvincesViewController，
        // 以便它为CitiesViewController设置delegate
        (destController as! ProvincesViewController).rootViewController = self
    }
    // 定义一个方法，获取属性列表文件的保存路径。
    lazy var filePath: String = {
        // 获取应用的Documents路径
        let paths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return "\(documentsDirectory)/cityList.plist"
    }()
    // 实现CityViewControllerDelegate协议中的方法,使用传进来的参数改变cityData集合的值,
    // 以便用户选中城市时将城市名称传给该视图控制器，从而直接显示最新的城市列表。
    func addCityToRootView(_ cityValue : String){
        // 只有当用户选择的城市不在城市列表内时，才将用户选择的城市添加到可变的数组集合中
        if !(cityData as NSArray).contains(cityValue) {
            // 将城市名称添加到可变数组
            cityData.append(cityValue)
            // 将最新的城市列表保存到底层的属性列表文件中
            (cityData as NSArray).write(toFile: self.filePath, atomically:true)
            // UITableView 刷新数据
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
