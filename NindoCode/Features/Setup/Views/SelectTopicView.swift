import SwiftUI
import CoreData

struct SelectTopicView: View {

    @ObservedObject var viewModel: SetupViewModel
    let onTopicSelected: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose a topic")
                        .font(.largeTitle)
                        .bold()

                    if let subject = viewModel.selectedSubject {
                        Text(subject)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 0) {
                    ForEach(viewModel.topicsForSelectedSubject, id: \.self) { topic in
                        Button {
                            viewModel.selectedTopic = topic
                            onTopicSelected()
                        } label: {
                            HStack {
                                Text(topic)
                                    .font(.headline)
                                    .foregroundStyle(.blue)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                        }

                        if topic != viewModel.topicsForSelectedSubject.last {
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
}

#Preview {
    let viewModel = SetupViewModel.previewMock(
        subjects: ["Swift"],
        topicsBySubject: [
            "Swift": [
                "Arrays",
                "Optionals",
                "Closures",
                "Protocols",
                "Concurrency"
            ]
        ],
        selectedSubject: "Swift"
    )

    SelectTopicView(
        viewModel: viewModel,
        onTopicSelected: {}
    )
}
