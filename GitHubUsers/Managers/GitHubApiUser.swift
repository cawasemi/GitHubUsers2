//
//  GitHubApiUser.swift
//  GitHubUsers
//
//  Created by Shusaku Harada on 2019/02/11.
//  Copyright © 2019 Shusaku Harada. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

/// 指定されたユーザーの情報を取得する。
class GitHubApiUser: GitHubApiRequest {
    
    // MARK: Request
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        let encoded: String = login.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
        return String(format: "/users/%@", encoded)
    }

    var parameters: Parameters? {
        return nil
    }
    
    var linkIndexKey: String {
        return ""
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1

    private var login: String

    init() {
        self.login = ""
    }

    func getUser(_ login: String) -> Promise<GitHubUser> {
        self.login = login
        return Promise<GitHubUser> { (resolver) in
            request.responseJSON { (response) in
                if let error = response.error {
                    resolver.reject(error)
                    return
                }

                if let resultValue = response.result.value {
                    let jsonData = SwiftyJSON.JSON(resultValue)
                    let user = GitHubUser(fromJson: jsonData)
                    resolver.fulfill(user)
                } else {
                    resolver.reject(GitHubApiRequestError.noResponseData)
                }
            }
        }
        // ---
    }
}

class GitHubApiUserRepositories: GitHubApiRequest {
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        let encoded: String = login.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
        return String(format: "/users/%@/repos", encoded)
    }
    
    var parameters: Parameters? {
        return ["page": pageNo]
    }
    
    var linkIndexKey: String {
        return "page"
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1

    private var login: String
    private var pageNo: Int
    
    init() {
        self.login = ""
        self.pageNo = 0
    }

    func next(_ pageNo: Int, login: String) -> Promise<[GitHubRepository]> {
        self.pageNo = pageNo
        self.login = login
        return Promise<[GitHubRepository]> { [weak self] (resolver) in
            request.responseJSON { (response) in
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
                        let repos = array.map({GitHubRepository(fromJson: $0)})
                        resolver.fulfill(repos)
                        return
                    }
                }
                resolver.reject(GitHubApiRequestError.noResponseData)
            }
        }
        // ---
    }
}
