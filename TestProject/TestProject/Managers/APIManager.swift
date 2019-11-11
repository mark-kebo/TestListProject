//
//  APIManager.swift
//  TestProject
//
//  Created by Dmitry Vorozhbicki on 07/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

protocol APIManagerProtocol {
    func sendRequest(url: String, parameters: Parameters?, method: HTTPMethod, encoding: ParameterEncoding, completion: @escaping (Data?, APIError?) -> Void)
}

class APIManager {
        
    static let sharedInstance = APIManager()

    private let manager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.httpMaximumConnectionsPerHost = 15
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    fileprivate let utilityQueue = DispatchQueue.main
    
    init() {
    //        let retrier = Retrier()
    //        manager.retrier = retrier
    }
}

extension APIManager: APIManagerProtocol {
    func sendRequest(url: String, parameters: Parameters?, method: HTTPMethod, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (Data?, APIError?) -> Void) {
        guard NetworkManager.sharedInstance.isNetworkReachable() else {
            completion(nil,APIError.noInternetConnection)
            return
        }
        manager.request(url, method: method, parameters: parameters, encoding: encoding, headers: Alamofire.SessionManager.defaultHTTPHeaders)
            .validate()
            .responseData(queue: utilityQueue, completionHandler: { [weak self] (response) in
                if let error = response.error {
                    print(String(describing: response.error?.localizedDescription))
                    if let request = response.request {
                        self?.handle(error:error, request:request) { error in
                            guard let error = error else {
                                self?.sendRequest(url: url, parameters: parameters, method: method, encoding: encoding, completion: completion)
                                return
                            }
                            if let data = response.data, let object = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:String] {
                                completion(nil,APIError.other(object["error"]))
                                return
                            }
                            completion(nil,APIError.other(error.localizedDescription))
                        }
                    }
                } else {
                    completion(response.result.value,nil)
                }
            })
    }
}

private extension APIManager {
    func handle(error:Error, request:URLRequest?, completion:@escaping ((Error?) ->())) {
        guard let request = request else {
            completion(error)
            print("\(Date()) - Can't Handle Error:  No request")
            return
        }
        if let error = error as? AFError {
            if let body = request.httpBody, let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
                print(error.localizedDescription + "Parameters: \(String(describing: json))")
            } else {
                print(error.localizedDescription)
            }
            completion(error)
        } else {
            completion(error)
        }
    }
}

extension APIManager {
    
    func getChannels(parameters: [String:String] = [:], completion:@escaping (Items?, APIError?) -> Void) {
        sendRequest(url: Constants.apiServer, parameters: parameters, method: .get) { (response, error) in
            if let error = error {
                completion(nil,error)
                return
            }
            if let data = response, let str = String.init(data: data, encoding: String.Encoding.utf8) {
                completion(Items(JSONString: str), nil)
            }

        }
    }
    
    static func downloadImage(for url:String, completion:@escaping ((UIImage?) -> ())) {
        Alamofire.request(url).responseImage { response in
            debugPrint(response)
            debugPrint(response.result)

            if let image = response.result.value {
                completion(image)
            }
        }
    }
}
