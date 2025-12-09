import SwiftUI
import CoreData

struct SelectSubjectView: View {

    @ObservedObject var viewModel: SetupViewModel
    let onNext: () -> Void

    var body: some View {
        List {
            ForEach(viewModel.subjects, id: \.self) { subject in
                Button(subject) {
                    viewModel.selectedSubject = subject
                    onNext()
                }
            }
        }
        .navigationTitle("Select subject")
    }
}

#Preview {
    let repo = QuestionRepository(context: PersistenceController.shared.container.viewContext)
    let vm = SetupViewModel(repository: repo)
    return SelectSubjectView(viewModel: vm, onNext: {})
}
