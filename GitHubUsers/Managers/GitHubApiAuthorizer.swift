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
import Himotoki

protocol GitHubApiRequest {
//    associatedtype Response: ResponseProtocol
    
    var baseURL: URL { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: Alamofire.Parameters? { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var headers: Alamofire.HTTPHeaders? { get }
    
    var linkIndexKey: String { get }
    var nextIndex: Int64 { get set }
    var lastIndex: Int64 { get set }
    
    func call() -> Promise<Bool>
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

    func call() -> Promise<Bool> {
        return Promise<Bool> { resolver in
            let url = baseURL.appendingPathComponent(path)
            
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate(statusCode: 200..<300).responseJSON { (response) in
                if let error = response.error {
                    resolver.reject(error)
                    return
                }
                resolver.fulfill(true)
            }
        }
    }
    
    var request: Alamofire.DataRequest {
        let url = baseURL.appendingPathComponent(path)
        
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    func parseIndexLink(_ `link`: String, target: String) -> Int64 {
        if linkIndexKey.isEmpty { return -1 }
        let links = link.components(separatedBy: ",")
        if links.isEmpty {
            return -1
        }
        guard let nextLink = links.first(where: {$0.contains("rel=\"\(target)\"")}) else {
            return -1
        }
        return parseIndex(from: nextLink)
    }
    
    private func parseLinkUrl(_ `link`: String) -> URL? {
        guard let endIndex = link.lastIndex(of: ">") else {
            return nil
        }
        let startIndex = link.index(link.startIndex, offsetBy: 1)
        let urlString = link[startIndex..<endIndex]
        return URL(string: String(urlString))
    }
    
    private func parseIndex(from nextLink: String) -> Int64 {
        if linkIndexKey.isEmpty { return -1 }
        guard let urlQuery = parseLinkUrl(nextLink)?.query,
            let sinceQuery = urlQuery.components(separatedBy: "&").first(where: {$0.contains(linkIndexKey)}) else {
                return -1
        }
        let work = sinceQuery.components(separatedBy: "=")
        if work.count != 2 {
            return -1
        }
        return Int64(work[1]) ?? -1
    }
}

protocol ResponseProtocol: Swift.Decodable {
    
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
    
    var linkIndexKey: String {
        return ""
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1
    
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
    
    var linkIndexKey: String {
        return "since"
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1

    init() {
        self.since = 0
        self.nextIndex = -1
        self.lastIndex = -1
    }
    
    func next(_ since: Int64) {
        self.since = since
        request.responseJSON {[weak self] (response) in
            if let error = response.error {
                dump(error)
                return
            }
            if let `link` = response.response?.allHeaderFields["Link"] as? String {
                self?.nextIndex = self?.parseIndexLink(link, target: "next") ?? -1
                self?.lastIndex = self?.parseIndexLink(link, target: "last") ?? -1
            }

            guard let resultValue = response.result.value else {
                return
            }
            print("\(#function)")
            let jsonData = SwiftyJSON.JSON(resultValue)
            if let array = jsonData.array {
                print("Array: ")
                print(array)
                array.forEach({ (item) in
                    let id = item["id"]
                    let login = item["login"]
                    let iconUrl = item["avatar_url"]
                    print("\(id) :: \(login)")
                })
            }
            if let dictionary = jsonData.dictionary {
                print("Dictionary: ")
                print(dictionary)
            }
            do {
                let workResult: [GitHubSearchUser] = try decodeArray(resultValue)
                print()
            } catch let error {
                dump(error)
            }
            print("----")
        }
    }
}
