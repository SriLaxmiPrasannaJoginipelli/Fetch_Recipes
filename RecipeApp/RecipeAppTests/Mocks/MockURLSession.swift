import Foundation

class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func dataTask(with url: URL) -> URLSessionDataTask {
        return MockURLSessionDataTask { [weak self] in
            if let error = self?.mockError {
                // Simulate error
                self?.mockError = error
                return
            }
            
            guard let data = self?.mockData, let response = self?.mockResponse else {
                // Simulate a bad server response
                self?.mockError = URLError(.badServerResponse)
                return
            }
            
            // Simulate returning data and response
            // You would typically use a completion handler here, like the real method does
            print("Returning mock data and response")
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let mockAction: () -> Void
    
    init(mockAction: @escaping () -> Void) {
        self.mockAction = mockAction
    }
    
    override func resume() {
        mockAction()
    }
}
