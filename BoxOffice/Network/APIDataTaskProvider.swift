//
//  APIDataTaskProvider.swift
//  BoxOffice
//
//  Created by john-lim on 2023/01/17.
//

import Foundation

struct APIDataTaskProvider {
    let session: URLSessionCallable
    let baseURL: String
    let query: [URLQueryItem]?
    let method: HTTPMethod
    
    init(session: URLSessionCallable = URLSession.shared,
         baseURL: String,
         query: [URLQueryItem]? = nil,
         method: HTTPMethod = .get) {
        
        self.session = session
        self.baseURL = baseURL
        self.query = query
        self.method = method
    }
    
    init(session: URLSessionCallable = URLSession.shared,
         apiInfo: APIInfo) {
        
        self.session = session
        self.baseURL = apiInfo.urlString
        self.query = apiInfo.query
        self.method = apiInfo.method
    }
        
    func dataTask(completion: @escaping (Data) -> ()) -> URLSessionDataTask? {
        guard let urlRequest = urlRequest() else {
            return nil
        }
        
        return self.session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("fail : ", error?.localizedDescription ?? "")
                return
            }
            
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                return
            }
            
            guard let data = data else {
                return
            }
            completion(data)
        }
    }
    
    private func urlRequest() -> URLRequest? {
        var urlComponents = URLComponents(string: self.baseURL)
        if let query = self.query {
            urlComponents?.queryItems = query
        }
        guard let url = urlComponents?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.method.rawValue
        return request
    }
}
