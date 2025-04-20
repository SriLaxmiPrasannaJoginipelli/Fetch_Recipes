//
//  MockURLProtocol.swift
//  RecipeAppTests
//
//  Created by Srilu Rao on 4/17/25.
//
import Foundation

class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubResponse: HTTPURLResponse?
    static var stubError: Error?
    static var mockData: [URL: Data] = [:]


    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.stubResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = MockURLProtocol.stubResponseData {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

