//
//  FlightAssistApp.swift
//  FlightAssist
//
//  Created by Jumana on 20/10/1447 AH.
//
import SwiftUI
import UserNotifications
import CloudKit

@main
struct FlightAssistApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self

        // طلب إذن الإشعارات
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    // استقبال الـ device token وحفظه في CloudKit
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")

        // حفظ الـ token في AppState عشان نستخدمه لاحقاً
        DispatchQueue.main.async {
            AppState.shared.deviceToken = tokenString
        }

        // لو اليوزر مسجل دخول — حفظ الـ token في CloudKit
        if let userRecord = AppState.shared.currentUser {
            saveTokenToCloudKit(token: tokenString, userRecord: userRecord)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }

    // استقبال الإشعار وهو التطبيق شغال
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // لما اليوزر يضغط على الإشعار
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped: \(userInfo)")
        // هنا تقدر تفتح صفحة معينة لما يضغط على الإشعار
        completionHandler()
    }

    // MARK: - Save Token to CloudKit

    private func saveTokenToCloudKit(token: String, userRecord: CKRecord) {
        let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase
        userRecord["deviceToken"] = token
        Task {
            try? await db.save(userRecord)
        }
    }
}
