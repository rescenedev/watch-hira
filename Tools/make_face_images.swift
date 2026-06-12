import AppKit

// 사진 워치 페이스용 가나 배경 이미지 생성기.
// 사용법: swiftc Tools/make_face_images.swift KanaCore/Sources/KanaCore/*.swift -o makefaces
//        ./makefaces <출력 디렉터리>
// Apple Watch Ultra 화면(422x514pt)의 2배 해상도로 렌더링하며,
// 상단 약 1/4은 시계 숫자가 들어갈 수 있게 비워 둔다.

let canvas = CGSize(width: 844, height: 1028)

func render(kana: Kana, word: KanaWord?, to url: URL) throws {
    let rect = CGRect(origin: .zero, size: canvas)
    let image = NSImage(size: canvas)
    image.lockFocus()

    let background = NSGradient(colors: [
        NSColor(calibratedRed: 0.05, green: 0.04, blue: 0.13, alpha: 1),
        NSColor(calibratedRed: 0.11, green: 0.08, blue: 0.27, alpha: 1),
        NSColor(calibratedRed: 0.17, green: 0.10, blue: 0.33, alpha: 1),
    ])!
    background.draw(in: rect, angle: 75)

    // 중앙의 큰 가나 (상단은 시계 영역으로 비워 두고 약간 아래에 배치)
    let glyphFont = NSFont(name: "HiraginoSans-W7", size: 470)
        ?? NSFont.systemFont(ofSize: 470, weight: .heavy)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.5)
    shadow.shadowOffset = NSSize(width: 0, height: -10)
    shadow.shadowBlurRadius = 28

    let glyph = NSAttributedString(string: kana.character, attributes: [
        .font: glyphFont,
        .foregroundColor: NSColor.white,
        .shadow: shadow,
    ])
    let glyphSize = glyph.size()
    glyph.draw(at: CGPoint(x: (canvas.width - glyphSize.width) / 2, y: 330))

    // 발음 (초록)
    let romaji = NSAttributedString(string: kana.romaji, attributes: [
        .font: NSFont.systemFont(ofSize: 110, weight: .bold),
        .foregroundColor: NSColor(calibratedRed: 0.42, green: 0.92, blue: 0.60, alpha: 1),
        .kern: 4,
    ])
    let romajiSize = romaji.size()
    romaji.draw(at: CGPoint(x: (canvas.width - romajiSize.width) / 2, y: 200))

    // 예시 단어
    if let word {
        let example = NSAttributedString(string: "\(word.word)  \(word.meaning)", attributes: [
            .font: NSFont.systemFont(ofSize: 64, weight: .medium),
            .foregroundColor: NSColor.white.withAlphaComponent(0.72),
        ])
        let exampleSize = example.size()
        example.draw(at: CGPoint(x: (canvas.width - exampleSize.width) / 2, y: 96))
    }

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "makefaces", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "PNG 인코딩 실패: \(kana.character)"])
    }
    try png.write(to: url)
}

@main
struct MakeFaceImages {
    static func main() throws {
        let outputRoot = URL(fileURLWithPath: CommandLine.arguments.count > 1
            ? CommandLine.arguments[1]
            : "./kana_faces")

        for script in KanaScript.allCases {
            let directory = outputRoot.appendingPathComponent(script.rawValue)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            let pool = KanaData.kana(script: script, groups: [.basic])
            for (index, kana) in pool.enumerated() {
                let word = KanaWordBank.randomWords(for: kana, count: 1).first
                let name = String(format: "%@_%02d_%@.png", script.rawValue, index + 1, kana.character)
                try render(kana: kana, word: word, to: directory.appendingPathComponent(name))
            }
            print("\(script.rawValue): \(pool.count)장 완료")
        }
        print("저장 위치: \(outputRoot.path)")
    }
}
