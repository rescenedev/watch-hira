#!/usr/bin/env python3
"""Tatoeba 한-일 문장쌍에서 어휘 예문을 추출해 KanaCore/TatoebaExamples.swift 생성.

데이터: Tatoeba (https://tatoeba.org) — CC BY 2.0 FR.
사람이 번역한 일본어↔한국어 문장쌍만 사용한다.

원칙:
  - 큐레이션(ExampleSentences.swift)에 이미 있는 단어는 건너뛴다(검증본 우선).
  - 단어가 '깨끗하게' 든 짧은(<=20자) 문장만, 그중 가장 짧은 것을 고른다.
    (앞 글자가 한자/촉음이 아니고, 뒤에 조사·문장부호가 오는 경우만 → 복합어 오매칭 차단)

사용법:
  python3 Tools/gen_tatoeba_examples.py
  (Tatoeba 덤프를 /tmp/tatoeba 에 캐시. 없으면 내려받는다.)
"""
import os, re, sys, json, subprocess, urllib.request

CACHE = "/tmp/tatoeba"
EXPORTS = "https://downloads.tatoeba.org/exports"
MAXLEN = 20
PARTICLE = set("はがをにでとへやのも、。！？…」』）)")
BAD_BEFORE = set("っんー")
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DECKS = ["JLPTN5Words", "JLPTN4Words", "JLPTN3Words", "TravelWords"]


def fetch(name, url):
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        print(f"downloading {url}", file=sys.stderr)
        urllib.request.urlretrieve(url, path)
    return path


def load_pairs():
    os.makedirs(CACHE, exist_ok=True)
    jb = fetch("jpn.tsv.bz2", f"{EXPORTS}/per_language/jpn/jpn_sentences.tsv.bz2")
    kb = fetch("kor.tsv.bz2", f"{EXPORTS}/per_language/kor/kor_sentences.tsv.bz2")
    lb = fetch("links.tar.bz2", f"{EXPORTS}/links.tar.bz2")
    if not os.path.exists(os.path.join(CACHE, "jpn.tsv")):
        subprocess.run(["bunzip2", "-kf", jb, kb], check=True)
        subprocess.run(["tar", "xjf", lb, "-C", CACHE], check=True)

    def texts(fn):
        d = {}
        for line in open(os.path.join(CACHE, fn), encoding="utf-8"):
            p = line.rstrip("\n").split("\t")
            if len(p) >= 3:
                d[p[0]] = p[2]
        return d

    jpn, kor = texts("jpn.tsv"), texts("kor.tsv")
    pairs = []
    for line in open(os.path.join(CACHE, "links.csv"), encoding="utf-8"):
        a, _, b = line.partition("\t")
        b = b.strip()
        if a in jpn and b in kor:
            pairs.append((jpn[a], kor[b]))
    return pairs


def deck_words():
    words = []
    for d in DECKS:
        t = open(os.path.join(ROOT, "KanaCore/Sources/KanaCore", d + ".swift"), encoding="utf-8").read()
        words += re.findall(r'v\("([^"]+)"', t)
    return list(dict.fromkeys(words))


def curated_keys():
    t = open(os.path.join(ROOT, "KanaCore/Sources/KanaCore/ExampleSentences.swift"), encoding="utf-8").read()
    return set(re.findall(r'^\s*"([^"]+)":\s*\.init', t, re.M))


def is_kanji(c):
    return "一" <= c <= "鿿"


def clean_match(j, w):
    i = j.find(w)
    while i != -1:
        before = j[i - 1] if i > 0 else ""
        after = j[i + len(w)] if i + len(w) < len(j) else ""
        ok_before = (i == 0) or (not is_kanji(before) and before not in BAD_BEFORE)
        ok_after = (after == "") or (after in PARTICLE)
        if ok_before and ok_after:
            return True
        i = j.find(w, i + 1)
    return False


def main():
    pairs = load_pairs()
    short = [(j, k) for (j, k) in pairs if len(j) <= MAXLEN]
    curated = curated_keys()
    out = {}
    for w in deck_words():
        if w in curated:
            continue
        cand = sorted((len(j), j, k) for (j, k) in short if clean_match(j, w))
        if cand:
            out[w] = (cand[0][1], cand[0][2])

    def esc(s):
        return s.replace("\\", "\\\\").replace('"', '\\"')

    path = os.path.join(ROOT, "KanaCore/Sources/KanaCore/TatoebaExamples.swift")
    with open(path, "w", encoding="utf-8") as f:
        f.write("import Foundation\n\n")
        f.write("// 자동 생성 — 직접 수정하지 말 것. (Tools/gen_tatoeba_examples.py)\n")
        f.write("// 예문 출처: Tatoeba Project (https://tatoeba.org) — CC BY 2.0 FR.\n")
        f.write("// 사람이 번역한 일본어↔한국어 문장쌍에서 추출한 단어별 예문.\n\n")
        f.write("/// Tatoeba 예문(단어 표기 → 예문). 큐레이션에 없는 단어의 빈자리를 채운다.\n")
        f.write("let tatoebaExamples: [String: ExampleSentence] = [\n")
        for w in sorted(out):
            j, k = out[w]
            f.write(f'    "{esc(w)}": .init(japanese: "{esc(j)}", korean: "{esc(k)}"),\n')
        f.write("]\n")
    print(f"wrote {len(out)} examples -> {path}")


if __name__ == "__main__":
    main()
