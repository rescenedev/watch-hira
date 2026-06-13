#if os(iOS)
import Foundation
import SQLite3
import ZIPFoundation

enum AnkiImportError: LocalizedError {
    case unreadableArchive
    case noCollection
    case modernFormatOnly
    case sqliteError(String)
    case empty

    var errorDescription: String? {
        switch self {
        case .unreadableArchive:
            return "파일을 열 수 없습니다. .apkg 파일이 맞는지 확인해 주세요."
        case .noCollection:
            return "패키지 안에서 단어 데이터를 찾지 못했습니다."
        case .modernFormatOnly:
            return "최신 Anki 포맷입니다. Anki에서 내보낼 때 '이전 버전 호환(Support older Anki versions)'을 체크해 주세요."
        case .sqliteError(let detail):
            return "데이터를 읽는 중 오류가 발생했습니다 (\(detail))."
        case .empty:
            return "덱에 단어가 없습니다."
        }
    }
}

/// Anki .apkg(zip + SQLite) 파서. 노트의 필드 텍스트만 추출한다.
enum AnkiImporter {

    struct RawNote: Hashable {
        let fields: [String]
    }

    static func loadNotes(from packageURL: URL) throws -> [RawNote] {
        let workDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("anki-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: workDir) }

        do {
            try FileManager.default.unzipItem(at: packageURL, to: workDir)
        } catch {
            throw AnkiImportError.unreadableArchive
        }

        let legacyCandidates = ["collection.anki21", "collection.anki2"]
        let dbURL = legacyCandidates
            .map { workDir.appendingPathComponent($0) }
            .first { FileManager.default.fileExists(atPath: $0.path) }

        guard let dbURL else {
            let modern = workDir.appendingPathComponent("collection.anki21b")
            if FileManager.default.fileExists(atPath: modern.path) {
                throw AnkiImportError.modernFormatOnly
            }
            throw AnkiImportError.noCollection
        }

        return try readNotes(dbPath: dbURL.path)
    }

    private static func readNotes(dbPath: String) throws -> [RawNote] {
        var db: OpaquePointer?
        guard sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            sqlite3_close(db)
            throw AnkiImportError.sqliteError("open")
        }
        defer { sqlite3_close(db) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, "SELECT flds FROM notes", -1, &statement, nil) == SQLITE_OK else {
            throw AnkiImportError.sqliteError("prepare")
        }
        defer { sqlite3_finalize(statement) }

        var notes: [RawNote] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            guard let cString = sqlite3_column_text(statement, 0) else { continue }
            let raw = String(cString: cString)
            let fields = raw
                .components(separatedBy: "\u{1F}")
                .map(cleanField)
            if fields.contains(where: { !$0.isEmpty }) {
                notes.append(RawNote(fields: fields))
            }
        }

        guard !notes.isEmpty else { throw AnkiImportError.empty }
        return notes
    }

    /// HTML 태그·[sound:...] 마커 제거.
    static func cleanField(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(
            of: #"\[sound:[^\]]*\]"#, with: "", options: .regularExpression
        )
        result = result.replacingOccurrences(
            of: #"<br\s*/?>"#, with: " ", options: [.regularExpression, .caseInsensitive]
        )
        result = result.replacingOccurrences(
            of: #"<[^>]+>"#, with: "", options: .regularExpression
        )
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
#endif
