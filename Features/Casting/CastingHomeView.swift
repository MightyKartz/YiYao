import SwiftUI

struct CastingHomeView: View {
    @State private var question = ""
    @State private var method: CastingMethod = .coins
    @State private var didPrepareCasting = false

    var body: some View {
        Form {
            Section("问题") {
                TextField("写下这次想记录的事", text: $question, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("方式") {
                Picker("起卦方式", selection: $method) {
                    ForEach(CastingMethod.allCases) { method in
                        Text(method.title).tag(method)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button {
                    didPrepareCasting = true
                } label: {
                    Label("起卦", systemImage: "sparkles")
                }
                .disabled(question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if didPrepareCasting {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("六爻结构", systemImage: "line.3.horizontal")
                            .font(.headline)
                        Text("本卦、动爻与变卦计算将在起卦引擎切片接入。")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

private enum CastingMethod: String, CaseIterable, Identifiable {
    case coins
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coins:
            "铜钱法"
        case .manual:
            "手动画爻"
        }
    }
}

#Preview {
    NavigationStack {
        CastingHomeView()
            .navigationTitle("起卦")
    }
}
