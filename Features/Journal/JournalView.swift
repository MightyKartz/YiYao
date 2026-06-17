import SwiftUI

struct JournalView: View {
    var body: some View {
        ContentUnavailableView {
            Label("暂无记录", systemImage: "book.closed")
        } description: {
            Text("保存后的问卦记录仅留在本机。")
        }
    }
}

#Preview {
    NavigationStack {
        JournalView()
            .navigationTitle("记录")
    }
}
