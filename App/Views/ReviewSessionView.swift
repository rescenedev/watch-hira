import SwiftUI
import KanaCore

/// 복습: 퀴즈에서 틀린 항목을 다시 본다.
/// 카드를 탭해 정답을 확인하고, 알면 ✓ — 두 번 맞히면 졸업한다.
struct ReviewSessionView: View {
    @ObservedObject private var store = ReviewStore.shared

    @State private var queue: [ReviewDisplay] = []
    @State private var currentIndex = 0
    @State private var isRevealed = false

    var body: some View {
        Group {
            if queue.isEmpty {
                emptyState
            } else if let item = currentItem {
                card(for: item)
            } else {
                finishedState
            }
        }
        .slateScreen()
        .navigationTitle("복습")
        .onAppear(perform: prepareQueue)
    }

    private var currentItem: ReviewDisplay? {
        queue.indices.contains(currentIndex) ? queue[currentIndex] : nil
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(Theme.mint)
            Text("복습할 항목이 없어요")
                .font(.headline)
            Text("퀴즈에서 틀린 문제가 여기에 모입니다")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var finishedState: some View {
        VStack(spacing: 10) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)
            Text("이번 복습 끝!")
                .font(.headline)
            if store.dueCount > 0 {
                Text("남은 항목 \(store.dueCount)개")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("한 번 더", action: prepareQueueFresh)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private func card(for item: ReviewDisplay) -> some View {
        VStack(spacing: 10) {
            Text("\(currentIndex + 1)/\(queue.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(item.prompt)
                .font(.system(size: promptSize, weight: .bold))
                .minimumScaleFactor(0.4)
                .lineLimit(1)

            if isRevealed {
                if let reading = item.reading {
                    Text(reading)
                        .font(.footnote.bold())
                        .foregroundStyle(Theme.mint)
                }
                Text(item.answer)
                    .font(.headline)
                    .foregroundStyle(Theme.mint)

                HStack(spacing: 10) {
                    Button {
                        skip()
                    } label: {
                        Label("아직", systemImage: "xmark")
                    }
                    .tint(.red)

                    Button {
                        markKnown(item)
                    } label: {
                        Label("알아요", systemImage: "checkmark")
                    }
                    .tint(.green)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("탭하여 정답 확인")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isRevealed { isRevealed = true }
        }
    }

    private var promptSize: CGFloat {
        #if os(watchOS)
        40
        #else
        88
        #endif
    }

    private func prepareQueue() {
        guard queue.isEmpty else { return }
        prepareQueueFresh()
    }

    private func prepareQueueFresh() {
        queue = store.dueItems.shuffled()
        currentIndex = 0
        isRevealed = false
    }

    private func markKnown(_ item: ReviewDisplay) {
        store.recordCorrect(id: item.id)
        next()
    }

    private func skip() {
        next()
    }

    private func next() {
        isRevealed = false
        currentIndex += 1
    }
}

#Preview {
    NavigationStack {
        ReviewSessionView()
    }
}
