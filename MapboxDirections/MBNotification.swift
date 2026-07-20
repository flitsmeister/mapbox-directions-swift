import Foundation

/**
 The type of a route leg notification.

 Notification types supported by the Directions API are `violation` and `alert`.
 `violation` is more severe and is delivered when user-set parameters (for example `exclude=unpaved`)
 are violated during route generation. `alert` is less severe and informs users when implicit
 preferences cannot be satisfied (for example `countryBorderCrossing`).

 Unknown values are preserved for forward compatibility.
 */
@objc(MBNotificationType)
public enum NotificationType: Int, CustomStringConvertible {
    /**
     An alert that is relevant to a route leg.
     */
    case alert

    /**
     The route leg violates a restriction.
     */
    case violation

    /**
     An unrecognized notification type returned by the Directions API.
     */
    case unknown

    public init(description: String) {
        switch description {
        case "alert":
            self = .alert
        case "violation":
            self = .violation
        default:
            self = .unknown
        }
    }

    public var description: String {
        switch self {
        case .alert:
            return "alert"
        case .violation:
            return "violation"
        case .unknown:
            return "unknown"
        }
    }
}

/**
 The optional subtype of a route leg notification.

 Unknown values are preserved for forward compatibility via `rawValue`.
 */
public struct NotificationSubtype: RawRepresentable, Hashable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        return rawValue
    }

    /**
     `type=violation` — The height of the vehicle is greater than the allowed height of the road.
     Provided when `max_height` is specified.
     */
    public static let maxHeight = NotificationSubtype(rawValue: "maxHeight")

    /**
     `type=violation` — The width of the vehicle is greater than the allowed width of the road.
     Provided when `max_width` is specified.
     */
    public static let maxWidth = NotificationSubtype(rawValue: "maxWidth")

    /**
     `type=violation` — The weight of the vehicle is greater than the allowed weight of the road.
     Provided when `max_weight` is specified.
     */
    public static let maxWeight = NotificationSubtype(rawValue: "maxWeight")

    /**
     `type=violation` — Unpaved road, while it was explicitly requested to exclude unpaved roads.
     Provided when `exclude=unpaved`.
     */
    public static let unpaved = NotificationSubtype(rawValue: "unpaved")

    /**
     `type=violation` — Road with tunnel, while it was explicitly requested to exclude tunnels.
     `type=alert` — Indicates a tunnel is on the route.
     */
    public static let tunnel = NotificationSubtype(rawValue: "tunnel")

    /**
     `type=violation` — Toll road, while it was explicitly requested to exclude toll roads.
     `type=alert` — Indicates a toll road is on the route.
     */
    public static let toll = NotificationSubtype(rawValue: "toll")

    /**
     `type=violation` — Undesirable road excluded by point.
     Provided when `exclude=point(longitude latitude)`.
     */
    public static let pointExclusion = NotificationSubtype(rawValue: "pointExclusion")

    /**
     `type=violation` / `type=alert` — Indicates a country border crossing.
     */
    public static let countryBorderCrossing = NotificationSubtype(rawValue: "countryBorderCrossing")

    /**
     `type=violation` / `type=alert` — Indicates a state border crossing.
     */
    public static let stateBorderCrossing = NotificationSubtype(rawValue: "stateBorderCrossing")

    /**
     `type=violation` — Indicates a ferry crossing. Provided when `exclude=ferry`.
     */
    public static let ferry = NotificationSubtype(rawValue: "ferry")
}

/**
 The refresh type of a notification, distinguishing static and dynamic notifications.

 Unknown values are preserved for forward compatibility via `rawValue`.
 */
public struct NotificationRefreshType: RawRepresentable, Hashable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        return rawValue
    }

    /**
     A notification received with the initial route request or a refresh, then kept constant.
     */
    public static let `static` = NotificationRefreshType(rawValue: "static")

    /**
     A notification that is updated and reset with each route refresh.
     */
    public static let dynamic = NotificationRefreshType(rawValue: "dynamic")
}

/**
 The reason why a notification was issued.
 */
public struct NotificationReason: RawRepresentable, Hashable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        return rawValue
    }

    public static let outOfOrder = NotificationReason(rawValue: "outOfOrder")
    public static let occupied = NotificationReason(rawValue: "occupied")
}

/**
 Details specific to a notification type and subtype.

 See the [Mapbox Directions API notification object](https://docs.mapbox.com/api/navigation/directions/#notification-object).
 */
@objc(MBNotificationDetails)
open class NotificationDetails: NSObject, NSSecureCoding {

    /**
     The optional requested value in the request.

     For example, it is `"3"` (meters) if `max_width=3` was specified in the request.
     */
    @objc public let requestedValue: String?

    /**
     The optional actual value associated with the property of the road.

     For example, it is `"2.5"` (meters) if the maximum road width is 2.5 meters.
     */
    @objc public let actualValue: String?

    /**
     The optional unit of measure associated with `actualValue` and `requestedValue`.
     */
    @objc public let unit: String?

    /**
     The optional message associated with the notification.
     */
    @objc public let message: String?

    /**
     Initializes notification details with the given values.
     */
    @objc public init(requestedValue: String? = nil, actualValue: String? = nil, unit: String? = nil, message: String? = nil) {
        self.requestedValue = requestedValue
        self.actualValue = actualValue
        self.unit = unit
        self.message = message
    }

    /**
     Initializes notification details from a JSON dictionary representation.
     */
    @objc(initWithJSON:)
    public convenience init(json: [String: Any]) {
        self.init(
            requestedValue: NotificationDetails.stringValue(from: json["requested_value"]),
            actualValue: NotificationDetails.stringValue(from: json["actual_value"]),
            unit: json["unit"] as? String,
            message: json["message"] as? String
        )
    }

    public required init?(coder decoder: NSCoder) {
        requestedValue = decoder.decodeObject(of: NSString.self, forKey: "requestedValue") as String?
        actualValue = decoder.decodeObject(of: NSString.self, forKey: "actualValue") as String?
        unit = decoder.decodeObject(of: NSString.self, forKey: "unit") as String?
        message = decoder.decodeObject(of: NSString.self, forKey: "message") as String?
    }

    @objc public static var supportsSecureCoding = true

    public func encode(with coder: NSCoder) {
        coder.encode(requestedValue, forKey: "requestedValue")
        coder.encode(actualValue, forKey: "actualValue")
        coder.encode(unit, forKey: "unit")
        coder.encode(message, forKey: "message")
    }

    /**
     A JSON dictionary representation using Directions API wire names.
     */
    public var json: [String: Any] {
        var dictionary: [String: Any] = [:]
        if let requestedValue = requestedValue {
            dictionary["requested_value"] = requestedValue
        }
        if let actualValue = actualValue {
            dictionary["actual_value"] = actualValue
        }
        if let unit = unit {
            dictionary["unit"] = unit
        }
        if let message = message {
            dictionary["message"] = message
        }
        return dictionary
    }

    private static func stringValue(from value: Any?) -> String? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }
}

/**
 A notification that is relevant to a route leg.

 According to the [Mapbox Directions API notification object](https://docs.mapbox.com/api/navigation/directions/#notification-object).
 */
@objc(MBNotification)
open class Notification: NSObject, NSSecureCoding {

    /**
     The type of notification (`alert` or `violation`).

     Unknown API values are exposed as `.unknown`; use `typeDescription` for the original wire value.
     */
    @objc public let type: NotificationType

    /**
     The original `type` string from the Directions API response.

     Preserved for forward compatibility when `type` is `.unknown`.
     */
    @objc public let typeDescription: String

    /**
     The optional subtype of the notification.

     Known values include `ferry`, `maxWidth`, `countryBorderCrossing`, and others defined by `NotificationSubtype`.
     */
    public let subtype: NotificationSubtype?

    /**
     The ObjC-compatible subtype string, if any.
     */
    @objc public var subtypeDescription: String? {
        return subtype?.rawValue
    }

    /**
     The refresh type distinguishing static and dynamic notifications.
     */
    public let refreshType: NotificationRefreshType

    /**
     The ObjC-compatible refresh type string.
     */
    @objc public var refreshTypeDescription: String {
        return refreshType.rawValue
    }

    /**
     The optional position in the coordinate list where the notification occurred, relative to the start of the leg.
     */
    public let geometryIndex: Int?

    /**
     The optional position in the coordinate list where the notification began, relative to the start of the leg.
     */
    public let geometryIndexStart: Int?

    /**
     The optional position in the coordinate list where the notification ended, relative to the start of the leg.
     */
    public let geometryIndexEnd: Int?

    /**
     The optional details specific to the notification type and subtype.
     */
    @objc public let details: NotificationDetails?

    /**
     Initializes a notification with the given values.
     */
    public init(type: NotificationType,
                typeDescription: String? = nil,
                subtype: NotificationSubtype? = nil,
                refreshType: NotificationRefreshType,
                geometryIndex: Int? = nil,
                geometryIndexStart: Int? = nil,
                geometryIndexEnd: Int? = nil,
                details: NotificationDetails? = nil) {
        self.type = type
        self.typeDescription = typeDescription ?? type.description
        self.subtype = subtype
        self.refreshType = refreshType
        self.geometryIndex = geometryIndex
        self.geometryIndexStart = geometryIndexStart
        self.geometryIndexEnd = geometryIndexEnd
        self.details = details
    }

    /**
     Initializes a notification from a JSON dictionary representation.

     Returns `nil` if required fields `type` or `refresh_type` are missing.
     */
    @objc(initWithJSON:)
    public convenience init?(json: [String: Any]) {
        guard let typeString = json["type"] as? String,
              let refreshTypeString = json["refresh_type"] as? String else {
            return nil
        }

        let subtype: NotificationSubtype?
        if let subtypeString = json["subtype"] as? String {
            subtype = NotificationSubtype(rawValue: subtypeString)
        } else {
            subtype = nil
        }

        let details: NotificationDetails?
        if let detailsJSON = json["details"] as? [String: Any] {
            details = NotificationDetails(json: detailsJSON)
        } else {
            details = nil
        }

        self.init(
            type: NotificationType(description: typeString),
            typeDescription: typeString,
            subtype: subtype,
            refreshType: NotificationRefreshType(rawValue: refreshTypeString),
            geometryIndex: json["geometry_index"] as? Int,
            geometryIndexStart: json["geometry_index_start"] as? Int,
            geometryIndexEnd: json["geometry_index_end"] as? Int,
            details: details
        )
    }

    public required init?(coder decoder: NSCoder) {
        guard let typeDescription = decoder.decodeObject(of: NSString.self, forKey: "typeDescription") as String?,
              let refreshTypeDescription = decoder.decodeObject(of: NSString.self, forKey: "refreshType") as String? else {
            return nil
        }

        type = NotificationType(description: typeDescription)
        self.typeDescription = typeDescription
        if let subtypeDescription = decoder.decodeObject(of: NSString.self, forKey: "subtype") as String? {
            subtype = NotificationSubtype(rawValue: subtypeDescription)
        } else {
            subtype = nil
        }
        refreshType = NotificationRefreshType(rawValue: refreshTypeDescription)

        if decoder.containsValue(forKey: "geometryIndex") {
            geometryIndex = decoder.decodeInteger(forKey: "geometryIndex")
        } else {
            geometryIndex = nil
        }
        if decoder.containsValue(forKey: "geometryIndexStart") {
            geometryIndexStart = decoder.decodeInteger(forKey: "geometryIndexStart")
        } else {
            geometryIndexStart = nil
        }
        if decoder.containsValue(forKey: "geometryIndexEnd") {
            geometryIndexEnd = decoder.decodeInteger(forKey: "geometryIndexEnd")
        } else {
            geometryIndexEnd = nil
        }

        details = decoder.decodeObject(of: NotificationDetails.self, forKey: "details")
    }

    @objc public static var supportsSecureCoding = true

    public func encode(with coder: NSCoder) {
        coder.encode(typeDescription, forKey: "typeDescription")
        coder.encode(subtype?.rawValue, forKey: "subtype")
        coder.encode(refreshType.rawValue, forKey: "refreshType")
        if let geometryIndex = geometryIndex {
            coder.encode(geometryIndex, forKey: "geometryIndex")
        }
        if let geometryIndexStart = geometryIndexStart {
            coder.encode(geometryIndexStart, forKey: "geometryIndexStart")
        }
        if let geometryIndexEnd = geometryIndexEnd {
            coder.encode(geometryIndexEnd, forKey: "geometryIndexEnd")
        }
        coder.encode(details, forKey: "details")
    }

    /**
     A JSON dictionary representation using Directions API wire names.
     */
    public var json: [String: Any] {
        var dictionary: [String: Any] = [
            "type": typeDescription,
            "refresh_type": refreshType.rawValue
        ]
        if let subtype = subtype {
            dictionary["subtype"] = subtype.rawValue
        }
        if let geometryIndex = geometryIndex {
            dictionary["geometry_index"] = geometryIndex
        }
        if let geometryIndexStart = geometryIndexStart {
            dictionary["geometry_index_start"] = geometryIndexStart
        }
        if let geometryIndexEnd = geometryIndexEnd {
            dictionary["geometry_index_end"] = geometryIndexEnd
        }
        if let details = details {
            dictionary["details"] = details.json
        }
        return dictionary
    }
}
