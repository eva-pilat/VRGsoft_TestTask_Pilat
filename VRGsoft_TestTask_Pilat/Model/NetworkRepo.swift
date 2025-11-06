//
//  NetworkRepo.swift
//  VRGsoft_TestTask_Pilat
//
//  Created by Єва Матвєєва on 03.11.2025.
//
import Foundation
import Alamofire

protocol NetworkService {
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> T
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct NetworkRequest {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let parameters: [String: Any]?

    init(url: URL, method: HTTPMethod = .get, headers: [String: String] = [:], body: Data? = nil, parameters: [String: Any] = [:]) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
    
//    var urlRequest: URLRequest {
//        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
//            fatalError("Invalid URL")
//        }
//        
//        if let parameters = parameters as? [String: String] {
//            urlComponents.queryItems = parameters.map {
//                URLQueryItem(name: $0.key, value: $0.value)
//            }
//        }
//        
//        guard let finalURL = urlComponents.url else {
//            fatalError("Could not build final URL with parameters")
//        }
//        
//        var request = URLRequest(url: finalURL)
//        request.httpMethod = method.rawValue
//        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
//        request.httpBody = body
//        return request
//    }
}

enum NetworkError: Error {
    case invalidResponse
    case decodingFailed
    case serverError(String)
}

final class AlamofireNetworkService: NetworkService {
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        let dataTask = AF.request(
            request.url,
            method: HTTPMethodConvert(request.method),
            parameters: request.parameters,
            encoding: URLEncoding.default,
            headers: HTTPHeaders(request.headers)
        )
        .serializingData()
        
        _ = await dataTask.response
        let result = await dataTask.result

        if let data = try? result.get() {
            if let json = try? JSONSerialization.jsonObject(with: data) {
                //print("API Response: \(json)")
            }
        }
        
        switch result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingFailed
            }
        case .failure(let afError):
            print("Network error: \(afError)")
            throw NetworkError.serverError(afError.localizedDescription)
        }
    }

    private func HTTPMethodConvert(_ method: HTTPMethod) -> Alamofire.HTTPMethod {
        switch method {
        case .get: return .get
        case .post: return .post
        }
    }
}

