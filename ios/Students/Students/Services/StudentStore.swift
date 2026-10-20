import Foundation
import SwiftUI

@MainActor
final class StudentStore: ObservableObject {
    @Published private(set) var students: [Student] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let api: StudentAPI

    init(api: StudentAPI = StudentAPI()) {
        self.api = api
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            students = try await api.fetchStudents().sorted {
                ($0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ student: Student) async -> Bool {
        errorMessage = nil
        do {
            if student.id == nil {
                let created = try await api.createStudent(student)
                students.append(created)
                students.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            } else {
                try await api.updateStudent(student)
                if let index = students.firstIndex(where: { $0.id == student.id }) {
                    students[index] = student
                }
                students.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(at offsets: IndexSet) async {
        let targets = offsets.map { students[$0] }
        for student in targets {
            guard let id = student.id else { continue }
            do {
                try await api.deleteStudent(id: id)
                students.removeAll { $0.id == id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func delete(_ student: Student) async {
        guard let id = student.id else { return }
        do {
            try await api.deleteStudent(id: id)
            students.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
