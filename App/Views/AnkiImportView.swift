#if os(iOS)
import SwiftUI
import KanaCore
import UniformTypeIdentifiers

/// Anki .apkg 파일을 골라 필드를 매핑하고 사용자 덱으로 저장한다.
struct AnkiImportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerPresented = false
    @State private var notes: [AnkiImporter.RawNote] = []
    @State private var deckName = ""
    @State private var wordField = 0
    @State private var readingField = -1
    @State private var meaningField = 1
    @State private var errorMessage: String?

    private var fieldCount: Int {
        notes.first?.fields.count ?? 0
    }

    var body: some View {
        List {
            if notes.isEmpty {
                pickSection
            } else {
                mappingSections
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
        }
        .slateScreen()
        .navigationTitle("Anki 가져오기")
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: allowedTypes,
            allowsMultipleSelection: false
        ) { result in
            handlePick(result)
        }
    }

    private var allowedTypes: [UTType] {
        var types: [UTType] = [.zip, .data]
        if let apkg = UTType(filenameExtension: "apkg") {
            types.insert(apkg, at: 0)
        }
        return types
    }

    private var pickSection: some View {
        Section {
            Button {
                isPickerPresented = true
            } label: {
                Label(".apkg 파일 선택", systemImage: "square.and.arrow.down")
            }
        } footer: {
            Text("최신 Anki에서 내보낼 때는 '이전 버전 호환(Support older Anki versions)'을 체크해야 합니다. 텍스트 필드만 가져오며 오디오·이미지는 제외됩니다.")
        }
    }

    @ViewBuilder
    private var mappingSections: some View {
        Section("덱 이름") {
            TextField("덱 이름", text: $deckName)
        }

        Section("필드 매핑 — 단어 \(notes.count)개") {
            fieldPicker("단어", selection: $wordField, allowNone: false)
            fieldPicker("읽기 (선택)", selection: $readingField, allowNone: true)
            fieldPicker("뜻", selection: $meaningField, allowNone: false)
        }

        if let sample = notes.first {
            Section("미리보기 (첫 번째 노트)") {
                ForEach(Array(sample.fields.enumerated()), id: \.offset) { index, field in
                    HStack {
                        Text("필드 \(index + 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(field.isEmpty ? "(비어 있음)" : field)
                            .lineLimit(1)
                    }
                }
            }
        }

        Section {
            Button("가져오기") {
                importDeck()
            }
            .disabled(deckName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private func fieldPicker(_ title: String, selection: Binding<Int>, allowNone: Bool) -> some View {
        Picker(title, selection: selection) {
            if allowNone {
                Text("없음").tag(-1)
            }
            ForEach(0..<fieldCount, id: \.self) { index in
                Text("필드 \(index + 1)").tag(index)
            }
        }
    }

    private func handlePick(_ result: Result<[URL], Error>) {
        errorMessage = nil
        guard case .success(let urls) = result, let url = urls.first else { return }

        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        do {
            notes = try AnkiImporter.loadNotes(from: url)
            deckName = url.deletingPathExtension().lastPathComponent
            let count = fieldCount
            wordField = 0
            meaningField = min(1, max(count - 1, 0))
            readingField = count >= 3 ? 1 : -1
            if count >= 3 { meaningField = 2 }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importDeck() {
        var seen = Set<String>()
        let words: [VocabWord] = notes.compactMap { note in
            guard note.fields.indices.contains(wordField),
                  note.fields.indices.contains(meaningField) else { return nil }
            let word = note.fields[wordField]
            let meaning = note.fields[meaningField]
            guard !word.isEmpty, !meaning.isEmpty, !seen.contains(word) else { return nil }
            seen.insert(word)

            let reading = note.fields.indices.contains(readingField)
                ? note.fields[readingField]
                : ""
            return VocabWord(
                word: word,
                reading: reading.isEmpty ? word : reading,
                meaning: meaning
            )
        }

        guard !words.isEmpty else {
            errorMessage = "선택한 필드 조합으로 가져올 단어가 없습니다."
            return
        }

        CustomDeckStore.shared.add(
            name: deckName.trimmingCharacters(in: .whitespaces),
            words: words
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AnkiImportView()
    }
}
#endif
