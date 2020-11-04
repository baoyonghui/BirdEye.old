//
//  ViewController.swift
//  birdeye
//
//  Created by yu xiaohe on 2020/10/21.
//

import UIKit
import SwiftHTTP
import DJISDK

open class FlyLineListViewController: UITableViewController{
    
    struct flyLineItem {
        var boundaryId:String!  // 航线ID
        var name:String!        // 航线名称
        var date:String!        // 创建日期
        var address:String!     // 地址
        var image:String!       // 航线截图
    }
    
    var items = [FlyLine]()
    
    @IBOutlet var headerLabel:UILabel?
    
    // 顶部刷新
    //let header = MJRefreshNormalHeader()
    
    // 顶部刷新
    @objc func headerRefresh(){
        print("下拉刷新")
        let sp:UserDefaults = UserDefaults.standard
        sp.setValue("AGR-AIMS-210ed2a87a00032c", forKey: "agri_mcfly_client_id")
        sp.setValue("6e016cf3-210ed32c9770072d", forKey: "agri_mcfly_key")
        sp.setValue("https://test-ecos-agr.pingan.com.cn/mcfly-gateway/agr-ecos.birdeye-server", forKey: "agri_mcfly_url_prefix")
        
        let userId:String = "65"
        let missionType:String = "1"
        let urlGetFlyLine:String = "/flyline/getFlyLines?userId=\(userId)&type=\(missionType)"
        let auth:WebiiAuthSignatureUtil = WebiiAuthSignatureUtil()
        //let key:String = "6e016cf3-210ed32c9770072d"
        //let data:String = "hello"
        let authedUrl:String = auth.genUrlAuth(url: urlGetFlyLine)
        HTTP.GET(authedUrl) { response in
            if let err = response.error{
                print ("error: \(err.localizedDescription)")
                return
            }
            //print ("opt finished: \(response.description)")
            let data:Data! = response.data
            do {
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                   let data = json["data"] as? [[String:Any]]{
                    self.items.removeAll()
                    for d in data{
                        //let address:String? = d["address"] as? String
                        //print (address ?? "")
                        
                        let flyLine:FlyLine = FlyLine(id:d["boundaryId"] as? Int, boundaryId:d["boundaryId"] as? String)
                        flyLine.acreage = d["acreage"] as? Double
                        flyLine.address = d["address"] as? String
                        
                        let boundaryObject:[[String: Double]] = d["boundary"] as? [[String: Double]] ?? []
                        var boondaryPoints:[[Double]] = []
                        for point in boundaryObject.enumerated() {
                            var lat:Double?
                            var lng:Double?
                            for (key, value) in point.element{
                                if key == "latitude" {
                                    lat = Double(value)
                                }else{
                                    lng = Double(value)
                                }
                            }
                            boondaryPoints.append([lng ?? 0, lat ?? 0])
                        }
                        //let lat:String? = boundaryObject?["latitude"]
                        
                        flyLine.boundary = boondaryPoints
                        flyLine.city = d["city"] as? String
                        flyLine.cityCode = d["cityCode"] as? String
                        flyLine.cropId = d["cropId"] as? String
                        flyLine.cropVarietyId = d["cropVarietyId"] as? String
                        flyLine.date = d["date"] as? String
                        flyLine.province = d["province"] as? String
                        flyLine.district = d["district"] as? String
                        flyLine.height = d["height"] as? Int
                        flyLine.overlap = d["overlap"] as? Int
                        flyLine.space = d["space"] as? Int
                        flyLine.speed = d["speed"] as? Int
                        flyLine.imageUrl = d["imageUrl"] as? String
                        flyLine.lat = d["lat"] as? Double
                        flyLine.lng = d["lng"] as? Double
                        flyLine.name = d["name"] as? String
                        flyLine.type = d["type"] as? Int
                        
                        let pointObject:[[String: Double]] = d["boundary"] as? [[String: Double]] ?? []
                        var pointPoints:[[Double]] = []
                        for point in pointObject.enumerated() {
                            var lat:Double?
                            var lng:Double?
                            for (key, value) in point.element{
                                if key == "latitude" {
                                    lat = Double(value)
                                }else{
                                    lng = Double(value)
                                }
                            }
                            pointPoints.append([lat ?? 0, lng ?? 0])
                        }
                        
                        flyLine.points = pointPoints
                        flyLine.userId = d["userId"] as? String
                        flyLine.weather = d["weather"] as? String
                        
                        //let item = flyLineItem(boundaryId:d["boundaryId"] as? String, name:d["name"] as? String, date:d["date"] as? String, address:d["address"] as? String, image:d["imageUrl"] as? String)
                        self.items.append(flyLine)
                    }
                    DispatchQueue.main.async() {
                        self.tableView.reloadData()
                        // 结束刷新
                        //self.tableView.mj_header?.endRefreshing()
                    }
                    
                    //print(json["message"] ?? "")
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    func setUp(){
        registerListeners()
        Environment.connectionService.start()
        // 下拉刷新
        self.headerRefresh()
        //header.setRefreshingTarget(self, refreshingAction: #selector(self.headerRefresh))
        // 现在的版本要用mj_header
        //self.tableView.mj_header = header
        //self.tableView.mj_header?.beginRefreshing()
        

    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.tableView.backgroundColor = UIColor.green
        setUp()
    }
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        self.headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: tableView.frame.size.width/2, height: 40))
        //label.text = "Product disconnected"
        self.headerLabel?.textColor = UIColor.red

        view.backgroundColor = UIColor.white
        view.addSubview(self.headerLabel!)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: tableView.frame.size.width/3*2, y: 20, width: tableView.frame.size.width/3, height: 40)
        button.setTitle("add", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        view.addSubview(button)

        return view
    }*/
    /*
    @objc func handleAdd(button: UIButton) {
        //self.navigationController?.pushViewController(Environment.rootViewController, animated: true)
        performSegue(withIdentifier: "showFlyLine", sender: self)
    }*/
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showFly"){
            let displayVC = segue.destination as! FlyViewController
            
            /*
             With iOS 13, as stated in the Platforms State of the Union during the WWDC 2019, Apple introduced a new default card presentation. In order to force the fullscreen you have to specify it explicitly with:
             */
            //displayVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            
            displayVC.flyLine = items[self.tableView.indexPathForSelectedRow!.row]
        }
    }
    
    /*override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }*/

    //===UITableViewDataSource===
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "testCellID"
        
        var cell:TableFlyLineCell? = tableView.dequeueReusableCell(withIdentifier: cellid) as? TableFlyLineCell
        if cell==nil {
            cell = TableFlyLineCell(style: .subtitle, reuseIdentifier: cellid)
        }
        
        let item:FlyLine = items[indexPath.row]
        let filename = getDocumentsDirectory().appendingPathComponent("\(item.boundaryId ?? "").png")
        
        if let data = try? Data.init(contentsOf: filename){
            
            let photo = UIImage.init(data: data)
            cell?.iconImv.image = photo//UIImage(named: item.imageUrl!)
        }else{
            cell?.iconImv.image = nil
        }
        
        cell?.userLabel.text = item.name
        cell?.sexLabel.text = item.address
        cell?.birthdayLabel.text = item.date
        return cell!
    }
    
    //===UITableViewDelegate===
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showFly", sender: self)
    }
    
    func showAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension FlyLineListViewController {
    // MARK : Product connection UI changes
    
    private func registerListeners() {
        
        Environment.connectionService.listeners.append({ model in
            print ("conn \(model ?? "aa")")
            if model == nil {
                print ("conn model is nil \(self.headerLabel == nil)")
                self.headerLabel?.text = "Product disconnected"
            } else {
                self.headerLabel?.text = model
            }
        })
    }
}

