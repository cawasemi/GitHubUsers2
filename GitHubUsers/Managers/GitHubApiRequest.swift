//
//  GitHubApiRequest.swift
//  GitHubUsers
//
//  Created by Shusaku Harada on 2019/02/23.
//  Copyright © 2019 Shusaku Harada. All rights reserved.
//

import Alamofire

enum GitHubApiRequestError: Error {
    case noResponseData
}

protocol GitHubApiRequest {
    var baseURL: URL { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: Alamofire.Parameters? { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var headers: Alamofire.HTTPHeaders? { get }
    
    var linkIndexKey: String { get }
    var nextIndex: Int64 { get set }
    var lastIndex: Int64 { get set }
}

extension GitHubApiRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }

    var headers: Alamofire.HTTPHeaders? {
        return ["Authorization": GitHubApiManager.shared.accessToken]
    }
    
    var request: Alamofire.DataRequest {
        let url = baseURL.appendingPathComponent(path)
        
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate(statusCode: 200..<300)
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
        let trimChars = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "<"))
        let trimmedLink = link.trimmingCharacters(in: trimChars)
        guard let endIndex = trimmedLink.lastIndex(of: ">") else {
            return nil
        }
        let startIndex = trimmedLink.startIndex
        let urlString = trimmedLink[startIndex..<endIndex]
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
