import Foundation

/// 단어 예문 한 쌍: 일본어 짧은 문장과 한국어 번역.
public struct ExampleSentence: Sendable, Equatable {
    public let japanese: String
    /// 번역(없으면 표시하지 않는다 — 폴백 예문 등).
    public let korean: String?

    public init(japanese: String, korean: String? = nil) {
        self.japanese = japanese
        self.korean = korean
    }
}

/// 단어별 짧은 예문 모음.
/// 자주 쓰는 단어는 자연스러운 예문을 직접 넣고,
/// 없는 단어는 어떤 표기든 문법적으로 성립하는 짧은 폴백 예문을 만든다.
public enum ExampleSentenceBank {

    /// 단어 표기로 예문을 찾는다. 큐레이션된 게 없으면 안전한 폴백 예문을 돌려준다.
    public static func sentence(forWord word: String) -> ExampleSentence {
        if let curated = table[word] {
            return curated
        }
        // 따옴표로 인용하면 품사와 무관하게 문장이 성립한다.
        return ExampleSentence(japanese: "「\(word)」を覚えました。")
    }

    private static let table: [String: ExampleSentence] = [
        // 사람·관계
        "私": .init(japanese: "私は学生です。", korean: "저는 학생이에요."),
        "先生": .init(japanese: "先生は親切です。", korean: "선생님은 친절해요."),
        "学生": .init(japanese: "私は学生です。", korean: "저는 학생이에요."),
        "友達": .init(japanese: "友達と遊びます。", korean: "친구와 놀아요."),
        "家族": .init(japanese: "家族が大好きです。", korean: "가족을 정말 좋아해요."),
        "父": .init(japanese: "父は会社員です。", korean: "아버지는 회사원이에요."),
        "母": .init(japanese: "母は料理が上手です。", korean: "어머니는 요리를 잘해요."),
        "子供": .init(japanese: "子供が三人います。", korean: "아이가 셋 있어요."),
        "人": .init(japanese: "あの人は誰ですか。", korean: "저 사람은 누구예요?"),
        "名前": .init(japanese: "名前を書いてください。", korean: "이름을 써 주세요."),

        // 일상·사물
        "水": .init(japanese: "水を飲みます。", korean: "물을 마셔요."),
        "お金": .init(japanese: "お金がありません。", korean: "돈이 없어요."),
        "時計": .init(japanese: "時計を見ます。", korean: "시계를 봐요."),
        "本": .init(japanese: "本を読みます。", korean: "책을 읽어요."),
        "車": .init(japanese: "車で行きます。", korean: "차로 가요."),
        "電車": .init(japanese: "電車に乗ります。", korean: "전철을 타요."),
        "食べ物": .init(japanese: "食べ物が好きです。", korean: "음식을 좋아해요."),
        "飲み物": .init(japanese: "飲み物はいかがですか。", korean: "마실 것 드릴까요?"),

        // 장소
        "駅": .init(japanese: "駅はどこですか。", korean: "역은 어디예요?"),
        "学校": .init(japanese: "学校へ行きます。", korean: "학교에 가요."),
        "空港": .init(japanese: "空港まで行きます。", korean: "공항까지 가요."),
        "病院": .init(japanese: "病院へ行きます。", korean: "병원에 가요."),
        "ホテル": .init(japanese: "ホテルを予約します。", korean: "호텔을 예약해요."),
        "トイレ": .init(japanese: "トイレはどこですか。", korean: "화장실은 어디예요?"),
        "道": .init(japanese: "道を教えてください。", korean: "길을 알려 주세요."),

        // 시간·날씨
        "時間": .init(japanese: "時間がありません。", korean: "시간이 없어요."),
        "今日": .init(japanese: "今日は忙しいです。", korean: "오늘은 바빠요."),
        "明日": .init(japanese: "明日会いましょう。", korean: "내일 만나요."),
        "天気": .init(japanese: "今日は天気がいいです。", korean: "오늘은 날씨가 좋아요."),

        // 여행·행동
        "旅行": .init(japanese: "日本へ旅行します。", korean: "일본으로 여행해요."),
        "約束": .init(japanese: "友達と約束があります。", korean: "친구와 약속이 있어요."),
        "切符": .init(japanese: "切符を買います。", korean: "표를 사요."),

        // 동사
        "食べる": .init(japanese: "ご飯を食べる。", korean: "밥을 먹어요."),
        "行く": .init(japanese: "学校へ行く。", korean: "학교에 가요."),
        "来る": .init(japanese: "友達が来る。", korean: "친구가 와요."),
        "見る": .init(japanese: "映画を見る。", korean: "영화를 봐요."),
        "飲む": .init(japanese: "お茶を飲む。", korean: "차를 마셔요."),
        "読む": .init(japanese: "本を読む。", korean: "책을 읽어요."),
        "書く": .init(japanese: "手紙を書く。", korean: "편지를 써요."),
        "買う": .init(japanese: "服を買う。", korean: "옷을 사요."),

        // 형용사
        "大きい": .init(japanese: "大きい家です。", korean: "큰 집이에요."),
        "小さい": .init(japanese: "小さい犬です。", korean: "작은 개예요."),
        "新しい": .init(japanese: "新しい車です。", korean: "새 차예요."),
        "古い": .init(japanese: "古い本です。", korean: "오래된 책이에요."),
        "高い": .init(japanese: "この店は高いです。", korean: "이 가게는 비싸요."),
        "安い": .init(japanese: "これは安いです。", korean: "이건 싸요."),
    ]
}
