import Foundation

enum StudentAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case encoding(Error)
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "Request failed with status \(code)."
        case .decoding(let error):
            return "Could not read server data: \(error.localizedDescription)"
        case .encoding(let error):
            return "Could not encode request: \(error.localizedDescription)"
        case .serverMessage(let message):
            return message
        }
    }
}

actor StudentAPI {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func fetchStudents() async throws -> [Student] {
        let request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("students.json"))
        return try await decode([Student].self, from: request)
    }

    func fetchStudent(id: Int) async throws -> Student {
        let request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("students/\(id).json"))
        return try await decode(Student.self, from: request)
    }

    func createStudent(_ student: Student) async throws -> Student {
        var request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("students.json"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try encoder.encode(StudentPayload(from: student))
        } catch {
            throw StudentAPIError.encoding(error)
        }
        return try await decode(Student.self, from: request)
    }

    func updateStudent(_ student: Student) async throws {
        guard let id = student.id else {
            throw StudentAPIError.serverMessage("Student is missing an id.")
        }
        var request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("students/\(id).json"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try encoder.encode(StudentPayload(from: student))
        } catch {
            throw StudentAPIError.encoding(error)
        }
        _ = try await perform(request)
    }

    func deleteStudent(id: Int) async throws {
        var request = URLRequest(url: APIConfiguration.baseURL.appendingPathComponent("students/\(id).json"))
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        _ = try await perform(request)
    }

    private func decode<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let data = try await perform(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StudentAPIError.decoding(error)
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw StudentAPIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if let errors = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let nameErrors = errors["name"] as? [String] {
                throw StudentAPIError.serverMessage(nameErrors.joined(separator: ", "))
            }
            throw StudentAPIError.httpStatus(http.statusCode)
        }
        return data
    }
}
