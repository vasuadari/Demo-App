import SwiftUI

struct StudentsListView: View {
    @EnvironmentObject private var store: StudentStore
    @State private var showingForm = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background

                VStack(alignment: .leading, spacing: 20) {
                    BrandMark()
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    if store.isLoading && store.students.isEmpty {
                        Spacer()
                        ProgressView("Loading students…")
                            .tint(AppTheme.ocean)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else if store.students.isEmpty {
                        emptyState
                    } else {
                        studentList
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingForm = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.ocean)
                    }
                    .accessibilityLabel("Add student")
                }
            }
            .sheet(isPresented: $showingForm) {
                StudentFormView(student: Student())
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
            .task {
                await store.load()
            }
            .refreshable {
                await store.load()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.55)) {
                    appeared = true
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.3")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(AppTheme.ocean)
                .symbolEffect(.pulse, options: .repeating)
            Text("No students yet")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Add a student to sync with your Rails Demo App.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.ink.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                showingForm = true
            } label: {
                Text("Add student")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(AppTheme.ocean, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .opacity(appeared ? 1 : 0)
    }

    private var studentList: some View {
        List {
            ForEach(Array(store.students.enumerated()), id: \.element.id) { index, student in
                NavigationLink(value: student) {
                    StudentRowView(student: student)
                }
                .listRowBackground(Color.white.opacity(0.72))
                .listRowSeparatorTint(AppTheme.mist)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.45).delay(Double(index) * 0.04), value: appeared)
            }
            .onDelete { offsets in
                Task { await store.delete(at: offsets) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Student.self) { student in
            StudentDetailView(student: student)
        }
    }
}

struct StudentRowView: View {
    let student: Student

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.ocean.opacity(0.9), AppTheme.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(student.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(student.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("Roll \(student.displayRollNo) · Year \(student.displayYear)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink.opacity(0.55))
            }
        }
        .padding(.vertical, 6)
    }
}
