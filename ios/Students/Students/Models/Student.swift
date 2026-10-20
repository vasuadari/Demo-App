import Foundation

struct Student: Identifiable, Codable, Hashable {
    var id: Int?
    var name: String
    var rollNo: Int?
    var year: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rollNo = "roll_no"
        case year
    }

    init(
        id: Int? = nil,
        name: String = "",
        rollNo: Int? = nil,
        year: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.rollNo = rollNo
        self.year = year
    }

    var displayRollNo: String {
        guard let rollNo else { return "—" }
        return String(rollNo)
    }

    var displayYear: String {
        guard let year else { return "—" }
        return String(year)
    }
}

struct StudentPayload: Encodable {
    let student: Fields

    struct Fields: Encodable {
        let name: String
        let roll_no: Int?
        let year: Int?
    }

    init(from student: Student) {
        self.student = Fields(
            name: student.name,
            roll_no: student.rollNo,
            year: student.year
        )
    }
}
