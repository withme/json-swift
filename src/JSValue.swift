//
//  JSON.swift
//  JSON
//
//  Created by David Owens on 6/20/14.
//  Copyright (c) 2014 David Owens II. All rights reserved.
//

/// A convenience type declaration for use with top-level JSON objects.
public typealias JSON = JSValue

/// The error domain for all `JSValue` related errors.
public let JSValueErrorDomain      = "com.kiadsoftware.json.error"

/// A representative type for all possible JSON values.
///
/// See http://json.org for a full description.
public struct JSValue : Equatable {

    /// The maximum integer that is safely representable in JavaScript.
    public static let MaximumSafeInt: Int64 = 9007199254740991
    
    /// The minimum integer that is safely representable in JavaScript.
    public static let MinimumSafeInt: Int64 = -9007199254740991


    /// The type of the underlying `JSArray`.
    public typealias JSArrayType       = [JSValue]

    /// The type of the underlying `JSObject`.
    public typealias JSObjectType      = [String:JSValue]
    
    /// The type of the underlying `JSString`.
    public typealias JSStringType      = String

    /// The type of the underlying `JSNumber`.
    public typealias JSNumberType      = Double

    /// The type of the underlying `JSBool`.
    public typealias JSBoolType        = Bool

    /// The underlying value for `JSValue`.
    var value: JSBackingValue
    
    
    /// All of the possible values that a `JSValue` can hold.
    enum JSBackingValue {
        /*
         * Implementation Note:
         *
         * I do not want consumers to be able to simply do JSValue.JSNumber(123) as I need to perform
         * validation on the input. This prevents me from simply using an enum. Thus I have this
         * strange nested enum to store the values. I'm not sure I like this approach, but I do not
         * see a better one at the moment...
         */
        
        /// Holds an array of JavaScript values that conform to valid `JSValue` types.
        case jsArray([JSValue])

        /// Holds an unordered set of key/value pairs conforming to valid `JSValue` types.
        case jsObject([String : JSValue])

        /// Holds the value conforming to JavaScript's String object.
        case jsString(String)
        
        /// Holds the value conforming to JavaScript's Number object.
        case jsNumber(Double)
        
        /// Holds the value conforming to JavaScript's Boolean wrapper.
        case jsBool(Bool)
        
        /// Holds the value that corresponds to `null`.
        case jsNull
        
        /// Holds the error information when the `JSValue` could not be made into a valid item.
        case invalid(Error)
    }

    /// Initializes a new `JSValue` with a `JSArrayType` value.
    public init(_ value: JSArrayType) {
        self.value = JSBackingValue.jsArray(value)
    }

    /// Initializes a new `JSValue` with a `JSObjectType` value.
    public init(_ value: JSObjectType) {
        self.value = JSBackingValue.jsObject(value)
    }

    /// Initializes a new `JSValue` with a `JSStringType` value.
    public init(_ value: JSStringType) {
        self.value = JSBackingValue.jsString(value)
    }

    /// Initializes a new `JSValue` with a `JSNumberType` value.
    public init(_ value: JSNumberType) {
        self.value = JSBackingValue.jsNumber(value)
    }
    
    /// Initializes a new `JSValue` with a `JSBoolType` value.
    public init(_ value: JSBoolType) {
        self.value = JSBackingValue.jsBool(value)
    }

    /// Initializes a new `JSValue` with an `Error` value.
    init(_ error: Error) {
        self.value = JSBackingValue.invalid(error)
    }

    /// Initializes a new `JSValue` with a `JSBackingValue` value.
    init(_ value: JSBackingValue) {
        self.value = value
    }
}

// All of the stupid number-type initializers because of the lack of type conversion.
// Grr... convenience initializers not allowed in this context...
// Also... without the labels, Swift cannot seem to actually get the type inference correct (6.1b3)
extension JSValue {
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(int8 value: Int8) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }

    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(in16 value: Int16) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }

    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(int32 value: Int32) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }

    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(int64 value: Int64) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }

    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(uint8 value: UInt8) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
    
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(uint16 value: UInt16) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
    
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(uint32 value: UInt32) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
    
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(uint64 value: UInt64) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }

    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(int value: Int) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
    
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(uint value: UInt) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
    
    /// Convenience initializer for a `JSValue` with a non-standard `JSNumberType` value.
    public init(float value: Float) {
        self.value = JSBackingValue.jsNumber(Double(value))
    }
}

extension JSValue : CustomStringConvertible {
    
    /// Attempts to convert the `JSValue` into its string representation.
    ///
    /// - parameter indent: the indent string to use; defaults to "  "
    ///
    /// - returns: A `FailableOf<T>` that will contain the `String` value if successful,
    ///           otherwise, the `Error` information for the conversion.
    public func stringify(_ indent: String = "  ") -> String {
        return prettyPrint(indent, 0)
    }
    
    /// Attempts to convert the `JSValue` into its string representation.
    ///
    /// - parameter indent: the number of spaces to include.
    ///
    /// - returns: A `FailableOf<T>` that will contain the `String` value if successful,
    ///           otherwise, the `Error` information for the conversion.
    public func stringify(_ indent: Int) -> String {
        let padding = (0..<indent).reduce("") { s, i in return s + " " }
        return prettyPrint(padding, 0)
    }
    
    /// Prints out the description of the JSValue value as pretty-printed JSValue.
    public var description: String {
        return stringify()
    }
}

/// Used to compare two `JSValue` values.
///
/// - returns: `True` when `hasValue` is `true` and the underlying values are the same; `false` otherwise.
public func ==(lhs: JSValue, rhs: JSValue) -> Bool {
    switch (lhs.value, rhs.value) {
    case (.jsNull, .jsNull):
        return true
        
    case let (.jsBool(lhsValue), .jsBool(rhsValue)):
        return lhsValue == rhsValue

    case let (.jsString(lhsValue), .jsString(rhsValue)):
        return lhsValue == rhsValue

    case let (.jsNumber(lhsValue), .jsNumber(rhsValue)):
        return lhsValue == rhsValue

    case let (.jsArray(lhsValue), .jsArray(rhsValue)):
        return lhsValue == rhsValue

    case let (.jsObject(lhsValue), .jsObject(rhsValue)):
        return lhsValue == rhsValue
        
    default:
        return false
    }
}

extension JSValue {
    func prettyPrint(_ indent: String, _ level: Int) -> String {
        let currentIndent = indent == "" ? "" : ((0...level).map({ (item: Int) in "" })).joined(separator: indent)
        let nextIndent = currentIndent + indent
        
        let newline = indent == "" ? "" : "\n"
        let space = indent == "" ? "" : " "
        
        switch self.value {
        case .jsBool(let bool):
            return bool ? "true" : "false"
            
        case .jsNumber(let number):
            return "\(number)"
            
        case .jsString(let string):
            let escaped = string.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
            
        case .jsArray(let array):
            return "[\(newline)" + (array.map({ "\(nextIndent)\($0.prettyPrint(indent, level + 1))" })) .joined(separator: ",\(newline)") + "\(newline)\(currentIndent)]"
            
        case .jsObject(let dict):
            return "{\(newline)" + (dict.map({ "\(nextIndent)\"\($0.replacingOccurrences(of: "\"", with: "\\\""))\":\(space)\($1.prettyPrint(indent, level + 1))"})).joined(separator: ",\(newline)") + "\(newline)\(currentIndent)}"
            
        case .jsNull:
            return "null"
            
        case .invalid(let error):
            return "<Invalid JSON: \(error.description)>"
            
        }
    }
}
