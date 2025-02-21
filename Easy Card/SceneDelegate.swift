import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              url.scheme == "easycard",
              url.host == "card",
              let cardId = url.pathComponents.last else {
            return
        }
        
        // 发送通知以打开卡片详情（发送字符串类型的 ID）
        NotificationCenter.default.post(
            name: Notification.Name("OpenCardDetail"),
            object: nil,
            userInfo: ["cardId": cardId]  // 直接发送字符串
        )
    }
} 