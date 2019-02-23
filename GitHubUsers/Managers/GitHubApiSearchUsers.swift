//
//  GitHubApiSearchUsers.swift
//  GitHubUsers
//
//  Created by Shusaku Harada on 2019/02/11.
//  Copyright © 2019 Shusaku Harada. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class GitHubApiAllUsers: GitHubApiRequest {
    var path: String {
        return "users"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return ["since": since]
    }
    
    var linkIndexKey: String {
        return "since"
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1
    
    private var since: Int64
    
    init() {
        self.since = 0
        self.nextIndex = -1
        self.lastIndex = -1
    }
    
    func next(_ since: Int64) -> Promise<[GitHubUser]> {
        self.since = since
        return Promise<[GitHubUser]> { (resolver) in
            request.responseJSON {[weak self] (response) in
                if let error = response.error {
                    resolver.reject(error)
                    return
                }
                if let `link` = response.response?.allHeaderFields["Link"] as? String {
                    self?.nextIndex = self?.parseIndexLink(link, target: "next") ?? -1
                    self?.lastIndex = self?.parseIndexLink(link, target: "last") ?? -1
                }
                
                if let resultValue = response.result.value {
                    let jsonData = SwiftyJSON.JSON(resultValue)
                    if let array = jsonData.array {
                        let users = array.map({GitHubUser(fromJson: $0)})
                        resolver.fulfill(users)
                        return
                    }
                }
                resolver.reject(GitHubApiRequestError.noResponseData)
            }
        }
        // ---
    }
}

class GitHubApiSearchUsers: GitHubApiRequest {
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/search/users"
    }
    
    var parameters: Parameters? {
        return ["q": query, "page": pageNo]
    }
    
    var linkIndexKey: String {
        return "page"
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1
    
    var query: String
    var pageNo: Int64
    
    init() {
        query = ""
        pageNo = 0
    }
    
    func next(query: String, pageNo: Int64) -> Promise<GitHubUsers> {
        self.query = query
        self.pageNo = pageNo
        return Promise<GitHubUsers> { (resolver) in
            request.responseJSON { [weak self] (response) in
                if let error = response.error {
                    resolver.reject(error)
                    return
                }
                if let `link` = response.response?.allHeaderFields["Link"] as? String {
                    self?.nextIndex = self?.parseIndexLink(link, target: "next") ?? -1
                    self?.lastIndex = self?.parseIndexLink(link, target: "last") ?? -1
                }
                
                guard let resultValue = response.result.value else {
                    resolver.reject(GitHubApiRequestError.noResponseData)
                    return
                }
                let jsonData = SwiftyJSON.JSON(resultValue)
                let users = GitHubUsers(fromJson: jsonData)
                resolver.fulfill(users)
            }
        }
        // ---
    }
}
