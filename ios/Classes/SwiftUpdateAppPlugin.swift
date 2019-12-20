import Flutter
import UIKit

public class SwiftUpdateAppPlugin: NSObject, FlutterPlugin {
    //Apple Store Link
    let appStoreLink = "https://itunes.apple.com/us/app/apple-store/id%@?mt=8"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cn.mofada.cn/update_app", binaryMessenger: registrar.messenger())
        let instance = SwiftUpdateAppPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateApp":
            goAppStore(call: call, result: result)
            break;
        case "checkUpdate":
            checkUpdate(call: call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func checkUpdate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            return
        }
        if let arguments = args as? [String: Any],
           let appleId = arguments["appleId"] as? String {
            //拼接地址
            let appStoreUrl = URL(string: String(format: appStoreLink, appleId))
            let localVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let request = NSMutableURLRequest(url: appStoreUrl!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "POST"
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) { (response, data, error) in

                // 声明获取的数据字典
                let receiveStatusDic = NSMutableDictionary()

                if data != nil {

                    do {
                        // JSON解析data
                        let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)

                        if let resultDic = dic as? [String: Any] {
                            // 取出版本号
                            // 判断是否resultCount为空
                            if let resultCount = resultDic["resultCount"] as? NSNumber {

                                // 判断resultCount的数量是否大于0
                                if resultCount.intValue > 0 {

                                    // 设置请求状态(1代表成功，0代表失败)
                                    receiveStatusDic.setValue("1", forKey: "status")

                                    // 判断results是否为空
                                    if let arr = resultDic["results"] as? NSArray {

                                        if let dict = arr.firstObject as? NSDictionary {

                                            // 取出version
                                            if let version = dict["version"] as? String {
                                                // 存网络版本号到UserDefaults里面
                                                if localVersion.compare(version) == ComparisonResult.orderedAscending {
                                                    DispatchQueue.main.async {
                                                        result(["version": version, "hasUpdate": true])
                                                    }

                                                    return
                                                }

                                            }
                                        }
                                    }
                                }
                            }
                        }

                    } catch _ {
                    }
                }
            }
        }
        result(result(["hasUpdate": false]))
    }


// 跳转Apple Store
    func goAppStore(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            return
        }

        if let arguments = args as? [String: Any],
        //获取Apple ID
           let appleId = arguments["appleId"] as? String {
            //拼接地址
            let appStoreUrl = URL(string: String(format: appStoreLink, appleId))
            if let url = appStoreUrl, UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            result(true)
        } else {
            result(false)
        }
    }

}
