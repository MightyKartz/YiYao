import SwiftUI

struct HexagramLibraryView: View {
    @State private var searchText = ""

    private var filteredHexagrams: [PreviewHexagram] {
        guard !searchText.isEmpty else { return PreviewHexagram.samples }
        return PreviewHexagram.samples.filter { item in
            item.name.localizedStandardContains(searchText)
                || item.subtitle.localizedStandardContains(searchText)
                || item.number.formatted().contains(searchText)
        }
    }

    var body: some View {
        List(filteredHexagrams) { hexagram in
            NavigationLink {
                HexagramPreviewDetailView(hexagram: hexagram)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(hexagram.number). \(hexagram.name)")
                        .font(.headline)
                    Text(hexagram.subtitle)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .searchable(text: $searchText, prompt: "搜索卦名")
    }
}

private struct HexagramPreviewDetailView: View {
    let hexagram: PreviewHexagram

    var body: some View {
        List {
            Section("卦象") {
                Text(hexagram.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(hexagram.subtitle)
                    .foregroundStyle(.secondary)
            }

            Section("白话提示") {
                Text(hexagram.note)
            }
        }
        .navigationTitle(hexagram.name)
    }
}

private struct PreviewHexagram: Identifiable {
    let id: Int
    let number: Int
    let name: String
    let subtitle: String
    let note: String

    static let samples = [
        PreviewHexagram(id: 1, number: 1, name: "乾", subtitle: "乾为天", note: "以刚健、主动、持续为主要意象。"),
        PreviewHexagram(id: 2, number: 2, name: "坤", subtitle: "坤为地", note: "以承载、顺势、厚重为主要意象。"),
        PreviewHexagram(id: 3, number: 3, name: "屯", subtitle: "水雷屯", note: "常用于理解初始阶段的阻力与生发。"),
        PreviewHexagram(id: 4, number: 4, name: "蒙", subtitle: "山水蒙", note: "提示学习、启蒙与辨明问题边界。")
    ]
}

#Preview {
    NavigationStack {
        HexagramLibraryView()
            .navigationTitle("卦库")
    }
}
