import XCTest
@testable import MapboxDirections

class NotificationTests: XCTestCase {
    func testRouteLegDeserializesNotifications() {
        let json: [String: Any] = [
            "distance": 100.0,
            "duration": 10.0,
            "summary": "",
            "steps": [],
            "notifications": [
                [
                    "type": "violation",
                    "subtype": "maxWidth",
                    "refresh_type": "static",
                    "geometry_index": 5,
                    "geometry_index_start": 4,
                    "geometry_index_end": 6,
                    "details": [
                        "requested_value": "3",
                        "actual_value": "2.5",
                        "unit": "m",
                        "message": "Width restriction"
                    ]
                ]
            ]
        ]

        let options = RouteOptions(coordinates: [
            .init(latitude: 0, longitude: 0),
            .init(latitude: 1, longitude: 1)
        ])
        let leg = RouteLeg(
            json: json,
            source: options.waypoints[0],
            destination: options.waypoints[1],
            options: options
        )

        XCTAssertEqual(leg.notifications.count, 1)
        let notification = leg.notifications[0]
        XCTAssertEqual(notification.type, .violation)
        XCTAssertEqual(notification.subtype, .maxWidth)
        XCTAssertEqual(notification.refreshType, .static)
        XCTAssertEqual(notification.geometryIndex, 5)
        XCTAssertEqual(notification.geometryIndexStart, 4)
        XCTAssertEqual(notification.geometryIndexEnd, 6)
        XCTAssertEqual(notification.details?.requestedValue, "3")
        XCTAssertEqual(notification.details?.actualValue, "2.5")
        XCTAssertEqual(notification.details?.unit, "m")
        XCTAssertEqual(notification.details?.message, "Width restriction")
    }

    func testRouteLegDeserializesPointAndRangeNotifications() {
        let json: [String: Any] = [
            "distance": 100.0,
            "duration": 10.0,
            "summary": "",
            "steps": [],
            "notifications": [
                [
                    "type": "alert",
                    "subtype": "countryBorderCrossing",
                    "refresh_type": "dynamic",
                    "geometry_index": 7
                ],
                [
                    "type": "violation",
                    "subtype": "ferry",
                    "refresh_type": "static",
                    "geometry_index_start": 10,
                    "geometry_index_end": 15
                ]
            ]
        ]

        let options = RouteOptions(coordinates: [
            .init(latitude: 0, longitude: 0),
            .init(latitude: 1, longitude: 1)
        ])
        let leg = RouteLeg(
            json: json,
            source: options.waypoints[0],
            destination: options.waypoints[1],
            options: options
        )

        XCTAssertEqual(leg.notifications.count, 2)

        let pointNotification = leg.notifications[0]
        XCTAssertEqual(pointNotification.type, .alert)
        XCTAssertEqual(pointNotification.subtype, .countryBorderCrossing)
        XCTAssertEqual(pointNotification.refreshType, .dynamic)
        XCTAssertEqual(pointNotification.geometryIndex, 7)
        XCTAssertNil(pointNotification.geometryIndexStart)
        XCTAssertNil(pointNotification.geometryIndexEnd)
        XCTAssertNil(pointNotification.details)

        let rangeNotification = leg.notifications[1]
        XCTAssertEqual(rangeNotification.type, .violation)
        XCTAssertEqual(rangeNotification.subtype, .ferry)
        XCTAssertEqual(rangeNotification.refreshType, .static)
        XCTAssertNil(rangeNotification.geometryIndex)
        XCTAssertEqual(rangeNotification.geometryIndexStart, 10)
        XCTAssertEqual(rangeNotification.geometryIndexEnd, 15)
    }

    func testNotificationPreservesUnknownValuesForForwardCompatibility() {
        let notification = Notification(json: [
            "type": "newType",
            "subtype": "newSubtype",
            "refresh_type": "newRefreshType"
        ])

        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.type, .unknown)
        XCTAssertEqual(notification?.typeDescription, "newType")
        XCTAssertEqual(notification?.subtype, NotificationSubtype(rawValue: "newSubtype"))
        XCTAssertEqual(notification?.refreshType, NotificationRefreshType(rawValue: "newRefreshType"))
    }

    func testNotificationRequiresTypeAndRefreshType() {
        XCTAssertNil(Notification(json: ["refresh_type": "static"]))
        XCTAssertNil(Notification(json: ["type": "alert"]))
    }

    func testNotificationAllowsMessageOnlyDetailsAndNoSubtype() {
        let notification = Notification(json: [
            "type": "alert",
            "refresh_type": "dynamic",
            "details": [
                "message": "Ferry service unavailable"
            ]
        ])

        XCTAssertNotNil(notification)
        XCTAssertNil(notification?.subtype)
        XCTAssertNil(notification?.geometryIndex)
        XCTAssertNil(notification?.geometryIndexStart)
        XCTAssertNil(notification?.geometryIndexEnd)
        XCTAssertNil(notification?.details?.requestedValue)
        XCTAssertNil(notification?.details?.actualValue)
        XCTAssertNil(notification?.details?.unit)
        XCTAssertEqual(notification?.details?.message, "Ferry service unavailable")
    }

    func testRouteLegWithoutNotificationsReturnsEmptyList() {
        let json: [String: Any] = [
            "distance": 100.0,
            "duration": 10.0,
            "summary": "",
            "steps": []
        ]

        let options = RouteOptions(coordinates: [
            .init(latitude: 0, longitude: 0),
            .init(latitude: 1, longitude: 1)
        ])
        let leg = RouteLeg(
            json: json,
            source: options.waypoints[0],
            destination: options.waypoints[1],
            options: options
        )

        XCTAssertEqual(leg.notifications.count, 0)
    }

    func testNotificationJSONUsesDirectionsWireNames() {
        let notification = Notification(
            type: .violation,
            subtype: nil,
            refreshType: .dynamic,
            geometryIndex: 5,
            geometryIndexStart: 4,
            geometryIndexEnd: 6,
            details: NotificationDetails(
                requestedValue: "3",
                actualValue: "2.5"
            )
        )

        let json = notification.json
        XCTAssertEqual(json["type"] as? String, "violation")
        XCTAssertEqual(json["refresh_type"] as? String, "dynamic")
        XCTAssertEqual(json["geometry_index"] as? Int, 5)
        XCTAssertEqual(json["geometry_index_start"] as? Int, 4)
        XCTAssertEqual(json["geometry_index_end"] as? Int, 6)
        XCTAssertNil(json["subtype"])

        let details = json["details"] as? [String: Any]
        XCTAssertEqual(details?["requested_value"] as? String, "3")
        XCTAssertEqual(details?["actual_value"] as? String, "2.5")
        XCTAssertNil(details?["unit"])
        XCTAssertNil(details?["message"])
        XCTAssertNil(notification.subtype)
    }

    func testNotificationSecureCodingRoundTrip() {
        let original = Notification(
            type: .alert,
            subtype: .ferry,
            refreshType: .static,
            geometryIndexStart: 10,
            geometryIndexEnd: 15,
            details: NotificationDetails(message: "Ferry ahead")
        )

        let data = try! NSKeyedArchiver.archivedData(withRootObject: original, requiringSecureCoding: true)
        let decoded = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Notification.self, from: data)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.type, .alert)
        XCTAssertEqual(decoded?.subtype, .ferry)
        XCTAssertEqual(decoded?.refreshType, .static)
        XCTAssertEqual(decoded?.geometryIndexStart, 10)
        XCTAssertEqual(decoded?.geometryIndexEnd, 15)
        XCTAssertEqual(decoded?.details?.message, "Ferry ahead")
    }

    func testNotificationDetailsCoercesNumericValuesToString() {
        let details = NotificationDetails(json: [
            "requested_value": 3,
            "actual_value": 2.5,
            "unit": "m",
            "message": "Width restriction"
        ])

        XCTAssertEqual(details.requestedValue, "3")
        XCTAssertEqual(details.actualValue, "2.5")
        XCTAssertEqual(details.unit, "m")
        XCTAssertEqual(details.message, "Width restriction")
    }
}
