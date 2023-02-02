//
//  APIDataTaskProvider.swift
//  BoxOffice
//
//  Created by john-lim on 2023/01/17.
//

import Foundation

class APIProvider {
    let session: URLSession
    var dataTask: URLSessionDataTask?
    let baseURL: String
    let header: [String: String]
    let query: [URLQueryItem]
    let method: HTTPMethod
    
    init(session: URLSession = URLSession.shared,
         baseURL: String,
         header: [String: String] = [:],
         query: [URLQueryItem] = [],
         method: HTTPMethod = .get) {
        self.session = session
        self.baseURL = baseURL
        self.header = header
        self.query = query
        self.method = method
    }
    
    init(session: URLSession = URLSession.shared,
         request: APIRequest) {
        self.session = session
        self.baseURL = request.urlString
        self.header = request.header
        self.query = request.query
        self.method = request.method
    }
    
    private func urlRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: self.baseURL)
        urlComponents?.queryItems = query
        
        guard let url = urlComponents?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = self.method.rawValue
        
        self.header.forEach { (key, value) in
            request.addValue(key, forHTTPHeaderField: value)
        }
        return request
    }
}

extension APIProvider: URLSessionCallable {
    func startLoading(completionHandler completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.dataTask?.cancel()
        
        guard let urlRequest = self.urlRequest() else {
            return
        }
        
        self.dataTask = session.dataTask(with: urlRequest){ data, response, error in
            if error != nil {
                print("fail : ", error?.localizedDescription ?? "")
            }
            
            let successsRange = 200..<300
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode) == false {
                print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
            }
            
            completion(data, response, error)
        }
        
        self.dataTask?.resume()
    }
    
    func stopLoading() {
        self.dataTask?.cancel()
    }
}
