import SwiftUI
import CoreData

struct QuizView: View {
    @StateObject var viewModel: QuizViewModel

    init(viewModel: QuizViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                HStack {
                    Text(viewModel.title)
                        .font(.title).bold()
                    Spacer()
                    Text("Pontos: \(viewModel.score)")
                        .font(.headline)
                        .accessibilityLabel("Pontuação \(viewModel.score)")
                }

                if let question = viewModel.currentQuestion {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.text)
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.leading)

                        VStack(spacing: 12) {
                            ForEach(Array(question.options.enumerated()), id: \.0) { idx, option in
                                Button {
                                    viewModel.selectOption(idx)
                                } label: {
                                    HStack {
                                        Text(option)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonBackground(
                                        idx: idx,
                                        isAnswered: viewModel.isAnswered,
                                        correctIndex: Int(question.correctIndex),
                                        selected: viewModel.selectedIndex)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(buttonBorder(
                                                idx: idx,
                                                isAnswered: viewModel.isAnswered,
                                                correctIndex: Int(question.correctIndex),
                                                selected: viewModel.selectedIndex
                                            ),
                                            lineWidth: 2
                                        )
                                    )
                                }
                                .disabled(viewModel.isAnswered)
                            }
                        }

                        HStack {
                            Button("Confirmar") {
                                viewModel.confirmAnswer()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.selectedIndex == nil || viewModel.isAnswered)

                            Spacer()

                            Button(viewModel.currentIndex + 1 >= viewModel.totalQuestions ? "Finalizar" : "Próxima") {
                                viewModel.nextQuestion()
                            }
                            .buttonStyle(.bordered)
                            .disabled(!viewModel.isAnswered)
                        }
                    }
                } else {
                    ContentUnavailableView("Sem perguntas",
                                           systemImage: "questionmark.circle",
                                           description: Text("Não há perguntas disponíveis.")
                    )
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .alert(
                "Quiz finalizado!",
                isPresented: Binding(
                    get: { viewModel.showFinished },
                    set: { _ in viewModel.dismissFinishedAlert() }
                )
            ) {
                Button("Reiniciar", role: .cancel) {
                    viewModel.restart()
                }
            } message: {
                Text("Sua pontuação: \(viewModel.score)")
            }
        }
    }

    private func buttonBackground(idx: Int, isAnswered: Bool, correctIndex: Int, selected: Int?) -> some ShapeStyle {
        if isAnswered {
            if idx == correctIndex { return Color.green.opacity(0.2) }
            if idx == selected { return Color.red.opacity(0.2) }
            return Color.gray.opacity(0.1)
        } else {
            if idx == selected { return Color.accentColor.opacity(0.15) }
            return Color.gray.opacity(0.08)
        }
    }

    private func buttonBorder(idx: Int, isAnswered: Bool, correctIndex: Int, selected: Int?) -> Color {
        if isAnswered {
            if idx == correctIndex { return .green }
            if idx == selected { return .red }
            return .clear
        } else {
            if idx == selected { return .accentColor }
            return .clear
        }
    }
}

#Preview {
    let repo = QuestionRepository(context: PersistenceController.shared.container.viewContext)
    let vm = QuizViewModel(repository: repo, filter: nil)
    QuizView(viewModel: vm)
}
