import SwiftUI

struct StudentFormView: View {
    @EnvironmentObject private var store: StudentStore
    @Environment(\.dismiss) private var dismiss

    @State private var student: Student
    @State private var rollText: String
    @State private var yearText: String
    @State private var isSaving = false
    @State private var localError: String?

    var onSaved: ((Student) -> Void)?

    private var isEditing: Bool { student.id != nil }

    init(student: Student, onSaved: ((Student) -> Void)? = nil) {
        _student = State(initialValue: student)
        _rollText = State(initialValue: student.rollNo.map(String.init) ?? "")
        _yearText = State(initialValue: student.year.map(String.init) ?? "")
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background

                Form {
                    Section {
                        TextField("Full name", text: $student.name)
                            .textInputAutocapitalization(.words)
                        TextField("Roll number", text: $rollText)
                            .keyboardType(.numberPad)
                        TextField("Year", text: $yearText)
                            .keyboardType(.numberPad)
                    } header: {
                        Text(isEditing ? "Edit student" : "New student")
                    } footer: {
                        Text("Changes are saved to the Rails Demo App API.")
                    }

                    if let localError {
                        Section {
                            Text(localError)
                                .foregroundStyle(.red)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit" : "Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving…" : "Save") {
                        Task { await save() }
                    }
                    .disabled(isSaving || student.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() async {
        localError = nil
        isSaving = true
        defer { isSaving = false }

        student.name = student.name.trimmingCharacters(in: .whitespacesAndNewlines)
        student.rollNo = Int(rollText.trimmingCharacters(in: .whitespacesAndNewlines))
        student.year = Int(yearText.trimmingCharacters(in: .whitespacesAndNewlines))

        let success = await store.save(student)
        if success {
            if let match = store.students.first(where: { $0.id == student.id }) ?? store.students.first(where: { $0.name == student.name }) {
                onSaved?(match)
            } else {
                onSaved?(student)
            }
            dismiss()
        } else {
            localError = store.errorMessage ?? "Could not save student."
        }
    }
}
