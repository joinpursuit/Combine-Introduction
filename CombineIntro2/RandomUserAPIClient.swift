import Foundation
import Combine

enum RandomUserAPIError: Error {
    case decodingError
    case rawError(Error)
    case noData
}

struct RandomUserAPIClient {
    static func randomUsersPublisher() -> AnyPublisher<[User], RandomUserAPIError> {
        let url = URL(string: "https://randomuser.me/api/?results=500")!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: UserAPIResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .mapError { RandomUserAPIError.rawError($0) }
            .eraseToAnyPublisher()
        return publisher
    }
    
    static func getRandomUsers(onCompletion: @escaping (Result<[User], RandomUserAPIError>) -> Void) {
        let url = URL(string: "https://randomuser.me/api/?results=500")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                onCompletion(.failure(.rawError(error)))
                return
            }
            guard let data = data else {
                onCompletion(.failure(.noData))
                return
            }
            do {
                let response = try JSONDecoder().decode(UserAPIResponse.self, from: data)
                let users = response.results
                onCompletion(.success(users))
            }
            catch {
                onCompletion(.failure(.decodingError))
            }
        }
    }
}
