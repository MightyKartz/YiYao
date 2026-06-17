import SwiftUI

enum SettingsCopy {
    static let privacyBody = LocalOnlyPolicy.privacyBody
    static let disclaimerBody = LocalOnlyPolicy.disclaimerBody
}

struct SettingsView: View {
    @State private var isShowingClearConfirmation = false

    var body: some View {
        Form {
            Section("隐私") {
                Text(SettingsCopy.privacyBody)
            }

            Section("免责声明") {
                Text(SettingsCopy.disclaimerBody)
            }

            Section("数据") {
                Button(role: .destructive) {
                    isShowingClearConfirmation = true
                } label: {
                    Label("清除本机记录", systemImage: "trash")
                }
            }
        }
        .confirmationDialog("清除本机记录", isPresented: $isShowingClearConfirmation) {
            Button("清除", role: .destructive) {}
            Button("取消", role: .cancel) {}
        } message: {
            Text("当前版本暂无已保存记录。")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .navigationTitle("设置")
    }
}
