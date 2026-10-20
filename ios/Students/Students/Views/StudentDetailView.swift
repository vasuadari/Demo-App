import SwiftUI

struct StudentDetailView: View {
    @EnvironmentObject private var store: StudentStore
    @Environment(\.dismiss) private var dismiss

    @State var student: Student
    @State private var showingEdit = false
    @State private var confirmDelete = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            AppTheme.background

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    detailBlock
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
        .navigationTitle("Student")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit") { showingEdit = true }
                    Button("Delete", role: .destructive) { confirmDelete = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppTheme.ocean)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            StudentFormView(student: student) { updated in
                student = updated
            }
        }
        .confirmationDialog("Delete this student?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.delete(student)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(student.name)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Synced with Demo App")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.ocean)
        }
    }

    private var detailBlock: some View {
        VStack(spacing: 0) {
            detailRow(label: "Roll number", value: student.displayRollNo)
            Divider().overlay(AppTheme.mist)
            detailRow(label: "Year", value: student.displayYear)
            if let id = student.id {
                Divider().overlay(AppTheme.mist)
                detailRow(label: "Record ID", value: String(id))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.ink.opacity(0.55))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.vertical, 14)
    }
}
