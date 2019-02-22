//
//  GitHubApiAuthorizer.swift
//  GitHubUsers
//
//  Created by Shusaku Harada on 2019/02/17.
//  Copyright © 2019 Shusaku Harada. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

protocol GitHubApiRequest {
//    associatedtype Response: ResponseProtocol
    
    var baseURL: URL { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: Alamofire.Parameters? { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var headers: Alamofire.HTTPHeaders? { get }
    
    func call() -> Promise<Void>
}

extension GitHubApiRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var headers: Alamofire.HTTPHeaders? {
        return ["Authorization": GitHubApiManager.shared.accessToken]
    }

    func call() -> Promise<Void> {
        return Promise<Void> { resolver in
            let url = baseURL.appendingPathComponent(path)
            
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate(statusCode: 200..<300).responseJSON { (response) in
                if let error = response.error {
                    resolver.resolve(error)
                    return
                }
                resolver.fulfill_()
            }
        }
    }
    
    var request: Alamofire.DataRequest {
        let url = baseURL.appendingPathComponent(path)
        
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }

}

protocol ResponseProtocol: Decodable {
    
}

class GitHubAuthorizer: GitHubApiRequest {
    var baseURL: URL {
        return URL(string: "https://github.com")!
    }

    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        return .post
    }

    var parameters: Parameters? {
        return ["client_id": "c82b3a07dbc4915a92d1", "client_secret": "c2477409c6951cf55310a096ae2b3dc9bdfd811f", "code": code]
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    private var code: String
    
    init(_ code: String) {
        self.code = code
    }
}

class GitHubAllUsers: GitHubApiRequest {
    var path: String {
        return "users"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return ["since": since]
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }

    private var since: Int64
    
    init() {
        self.since = 0
    }
    
    func next(_ since: Int64) {
        self.since = since
        request.responseJSON { (response) in
            
        }
    }
}
