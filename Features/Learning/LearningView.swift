import SwiftUI

struct LearningView: View {
    var body: some View {
        List {
            Section("阴阳") {
                Text("阴阳用于描述相对、互补与变化的关系。")
            }

            Section("八卦") {
                Text("八卦由三爻组成，常用来表示自然现象与处境结构。")
            }

            Section("六十四卦") {
                Text("六十四卦由上下两个三爻卦相叠而成，用来观察变化中的层次。")
            }

            Section("动爻与变卦") {
                Text("动爻表示变化发生的位置；变卦用于记录变化后的结构。")
            }
        }
    }
}

#Preview {
    NavigationStack {
        LearningView()
            .navigationTitle("学习")
    }
}
