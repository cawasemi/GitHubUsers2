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

class GitHubApiAuthorizer: GitHubApiRequest {
    var baseURL: URL {
        return URL(string: "https://github.com")!
    }

    var path: String {
        return "/login/oauth/access_token"
    }
    
    var method: HTTPMethod {
        return .post
    }

    var parameters: Parameters? {
        return ["client_id": "c82b3a07dbc4915a92d1", "client_secret": "c2477409c6951cf55310a096ae2b3dc9bdfd811f", "code": code]
    }
    
    var headers: HTTPHeaders? {
        return ["Accept": "application/json"]
    }
    
    var linkIndexKey: String {
        return ""
    }
    var nextIndex: Int64 = -1
    var lastIndex: Int64 = -1
    
    private var code: String 
    
    init() {
        self.code = ""
    }
    
    func authorizer(_ code: String) -> Promise<String> {
        self.code = code
        return Promise<String> { resolver in
            request.responseJSON { (response) in
                if let error = response.error {
                    resolver.reject(error)
                    return
                }
                var accessToken: String? = nil
                if let resultValue = response.result.value {
                    let jsonData = SwiftyJSON.JSON(resultValue)
                    accessToken = jsonData["access_token"].string
                }
                if let token = accessToken {
                    resolver.fulfill(token)
                } else {
                    resolver.reject(GitHubApiRequestError.noResponseData)
                }
            }
        }
        // ---
    }
}
