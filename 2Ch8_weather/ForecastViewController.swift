//
//  ForecastViewController.swift
//  2Ch8_weather
//
//  Created by Cary Song on 2017/7/20.
//  Copyright © 2017年 Cary Song. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    var weatherString: String!
    var labels = [UILabel]()
    var icons = [UIImageView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewSize = self.view.bounds.size
        // 所有UILabel的前面有2个天气图标（宽70）和2个间隔（宽10）
        let labelX: CGFloat = 70 * 2 + 10 * 3
        // 共显示3天的天气，计算每天天气区域的高度。
        let areaHeight = (viewSize.height - 64) / 3
        let lineHeight: CGFloat = 26  // 定义每条信息的高度
        let lineGap: CGFloat = 10  // 定义每条信息之间的间距
        // 计算每个天气区域上下的间隔
        let yGap = (areaHeight - lineHeight * 4 - lineGap * 3) / 2
        // 采用循环添加12个UILabel，用于显示天气情况
        for i in 0 ..< 12 {
            // 计算各区域的Y坐标
            let areaY = CGFloat(i / 4) * areaHeight + 64
            let label = UILabel(frame:CGRect(x: labelX,
                                             y: areaY + yGap + CGFloat(i % 4) * (lineHeight + lineGap), width: viewSize.width - labelX - 10, height: lineHeight))
            self.view.addSubview(label)
            label.font = UIFont.systemFont(ofSize: 13)
            labels.append(label)
        }
        // 采用循环添加6个UIImageView，用于显示天气图标
        for i in 0 ..< 6 {
            let iv = UIImageView(frame:CGRect(x: 10 + CGFloat(i % 2 * 80),
                                              y: 64 + CGFloat(i / 2) * areaHeight + areaHeight / 2 - 65 / 2,
                                              width: 70, height: 65))
            self.view.addSubview(iv)
            icons.append(iv)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 根据responseString获取一个XML Document
        let doc = try! DDXMLDocument(xmlString:self.weatherString, options:1)
        // 获取根节点对象
        let rootElement = doc.rootElement()
        // 获取<string.../>子元素，返回数组对象
        let dataElements = rootElement?.elements(forName: "string")
        self.title = "\((dataElements?[1] as AnyObject).stringValue!)天气"
        // ------下面代码就是根据不同的<string.../>元素的值来设置界面上UILabel的值------
        // 将索引为6的<string.../>元素的字符串内容按空格分成2个部分
        let tomorrows = (dataElements?[6] as AnyObject).stringValue.components(separatedBy: " ")
        labels[0].text = "日期：\(tomorrows[0])"
        labels[1].text = "天气：\(tomorrows[1])"
        labels[2].text = "气温：\((dataElements?[5] as AnyObject).stringValue!)"
        labels[3].text = "风力：\((dataElements?[7] as AnyObject).stringValue!)"
        // 将索引为13的<string.../>元素的字符串内容按空格分成2个部分
        let twoDays = (dataElements?[13] as AnyObject).stringValue.components(separatedBy: " ")
        labels[4].text = "日期：\(twoDays[0])"
        labels[5].text = "天气：\(twoDays[1])"
        labels[6].text = "气温：\((dataElements?[12] as AnyObject).stringValue!)"
        labels[7].text = "风力：\((dataElements?[14] as AnyObject).stringValue!)"
        // 将索引为18的<string.../>元素的字符串内容按空格分成2个部分
        let threeDays = (dataElements?[18] as AnyObject).stringValue
            .components(separatedBy: " ")
        labels[8].text = "日期：\(threeDays[0])"
        labels[9].text = "天气：\(threeDays[1])"
        labels[10].text = "气温：\((dataElements?[17] as AnyObject).stringValue!)"
        labels[11].text = "风力：\((dataElements?[19] as AnyObject).stringValue!)"
        // ----下面代码就是根据不同的<string.../>元素的值来设置界面上UIImageView的图片----
        icons[0].image = UIImage(named:"legend/a_\((dataElements?[8] as AnyObject).stringValue!)")
        icons[1].image = UIImage(named:"legend/a_\((dataElements?[9] as AnyObject).stringValue!)")
        icons[2].image = UIImage(named:"legend/a_\((dataElements?[15] as AnyObject).stringValue!)")
        icons[3].image = UIImage(named:"legend/a_\((dataElements?[16] as AnyObject).stringValue!)")
        icons[4].image = UIImage(named:"legend/a_\((dataElements?[20] as AnyObject).stringValue!)")
        icons[5].image = UIImage(named:"legend/a_\((dataElements?[21] as AnyObject).stringValue!)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
