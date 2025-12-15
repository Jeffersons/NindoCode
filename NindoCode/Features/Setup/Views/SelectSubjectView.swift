import SwiftUI
import CoreData

struct SelectSubjectView: View {
    @ObservedObject var viewModel: SetupViewModel
    let onSubjectSelected: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text("Choose a subject")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 0) {
                ForEach(viewModel.subjects, id: \.self) { subject in
                    Button {
                        viewModel.selectedSubject = subject
                        onSubjectSelected()
                    } label: {
                        HStack {
                            Text(subject)
                                .font(.headline)
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }

                    if subject != viewModel.subjects.last {
                        Divider()
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let repo = QuestionRepository(context: PersistenceController.shared.container.viewContext)
    let vm = SetupViewModel(repository: repo)
    SelectSubjectView(viewModel: vm, onSubjectSelected: {})
}
