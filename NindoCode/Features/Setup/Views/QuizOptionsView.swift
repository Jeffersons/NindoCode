import SwiftUI

struct QuizOptionsView: View {

    @ObservedObject var viewModel: SetupViewModel

    let onStartQuiz: () -> Void
    let onBack: () -> Void

    private let questionOptions = [5, 10, 15, 20]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Quiz setup")
                    .font(.largeTitle)
                    .bold()

                if let subject = viewModel.selectedSubject {
                    Text(subject)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                if let topic = viewModel.selectedTopic {
                    Text(topic)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Number of questions
            VStack(alignment: .leading, spacing: 16) {
                Text("Número de perguntas")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(questionOptions, id: \.self) { count in
                        Button {
                            viewModel.numberOfQuestions = count
                        } label: {
                            Text("\(count)")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    viewModel.numberOfQuestions == count
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.gray.opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }

            Spacer()

            // Actions
            HStack {
                Button("Voltar") {
                    onBack()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Iniciar quiz") {
                    onStartQuiz()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.numberOfQuestions <= 0)
            }
        }
        .padding()
        .navigationBarHidden(true)
    }
}
