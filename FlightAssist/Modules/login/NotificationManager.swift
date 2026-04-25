//
//  NotificationManager.swift
//  FlightAssist
//
//  Created by Jumana on 04/11/1447 AH.
//

import CloudKit
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()
    private let db = CKContainer(identifier: "iCloud.com.Jumana.Project").publicCloudDatabase

    // يُستدعى بعد الـ login مباشرة
    func subscribeToSwapRequests(for userID: String) {
        // اشتراك على أي SeatSwapRequest جديد يكون receiver_id = userID
        let predicate = NSPredicate(format: "receiver_id == %@", userID)

        let subscription = CKQuerySubscription(
            recordType: "SeatSwapRequest",
            predicate: predicate,
            subscriptionID: "swap-request-\(userID)",
            options: .firesOnRecordCreation
        )

        // إعداد الإشعار
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Seat Swap Request ✈️"
        notificationInfo.alertBody = "Someone wants to swap seats with you!"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true

        subscription.notificationInfo = notificationInfo

        // حفظ الـ subscription في CloudKit
        db.save(subscription) { _, error in
            if let error = error {
                // لو الـ subscription موجود أصلاً ما يعتبر خطأ
                print("Subscription error (may already exist): \(error.localizedDescription)")
            } else {
                print("✅ Subscribed to swap requests for user: \(userID)")
            }
        }
    }

    // إلغاء الاشتراك عند تسجيل الخروج
    func unsubscribe(for userID: String) {
        db.delete(withSubscriptionID: "swap-request-\(userID)") { _, error in
            if let error = error {
                print("Unsubscribe error: \(error.localizedDescription)")
            } else {
                print("✅ Unsubscribed for user: \(userID)")
            }
        }
    }
}
