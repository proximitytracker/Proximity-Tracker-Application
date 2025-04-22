//
//  AdvertisementDecoder.swift
//  Tag Scanner
//
//  Created by Jeffrey Abraham on 14.05.22.
//

import CoreBluetooth

/// Extracts the service data for a specified service key from the advertisement data and returns it as a hex string.
/// - Parameters:
///   - advertisementData: The dictionary containing Bluetooth LE advertisement data (keyed by CoreBluetooth advertisement constants).
///   - key: The string representation of the service UUID to look up in the advertisement data.
/// - Returns: A hex string representing the service data if the key is found, otherwise `nil`.
func getServiceData(advertisementData: [String: Any], key: String) -> String? {
    // Attempt to retrieve the service data dictionary from the advertisement data.
    let servData = advertisementData[CBAdvertisementDataServiceDataKey]
    
    // Check if the advertisement data contains a service data dictionary (with CBUUID keys and Data values).
    if let servData = servData as? [CBUUID: Data] {
        // Look for the specific service data using the provided key (as a CBUUID).
        if let data = servData[CBUUID(string: key)] {
            // Convert the retrieved Data object into a hexadecimal string.
            let hex = data.hexEncodedString()
            // Return the hex string representation of the service data.
            return hex
        }
    }
    // Return nil if the service data for the specified key was not found.
    return nil
}

/// Extracts all service data keys present in the advertisement data and returns them as an array of UUID strings.
/// - Parameter advertisementData: The advertisement data dictionary to examine.
/// - Returns: An array of service UUID strings if service data is available, otherwise an empty array.
func getServiceDataKeys(advertisementData: [String: Any]) -> [String] {
    // Attempt to retrieve the service data dictionary from the advertisement data.
    let servData = advertisementData[CBAdvertisementDataServiceDataKey]
    
    // Check if the advertisement data contains a service data dictionary.
    if let servData = servData as? [CBUUID: Data] {
        // Convert each service CBUUID key to its string representation and return the list.
        return servData.keys.map({ $0.uuidString })
    }
    // Return an empty array if there is no service data or no service data keys.
    return []
}

/// Extension of Data providing a method to convert its bytes to a hex string.
extension Data {
    /// Returns a hexadecimal string representation of this data.
    /// Each byte is converted into two hexadecimal characters.
    func hexEncodedString() -> String {
        // Format string to output each byte as two hex digits (lowercase).
        let format = "%02hhx"
        // Map each byte in the data to a 2-digit hex string, then join all hex segments into one string.
        return self.map { String(format: format, $0) }.joined()
    }
}

/// Extension of String providing a computed property to convert a hex string to Data.
extension String {
    /// Converts the string to a Data object by interpreting its contents as hexadecimal.
    /// Non-hex characters are ignored, and the string must not start with "0x".
    /// - Returns: A Data object containing the bytes represented by the hex string, or nil if the string is not valid hex.
    var hexadecimal: Data? {
        // Compute the number of bytes needed (1 byte per 2 hex characters, round up for odd length).
        var data = Data(capacity: Int(ceil(Double(count) / 2)))
        
        // Prepare a regular expression to find pairs of hex digits (allowing a single leftover digit).
        let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        
        // Iterate over each regex match (each match corresponds to one byte).
        regex?.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            if let match = match {
                // Extract the matched substring (1 or 2 hex characters) representing a byte.
                let byteString = (self as NSString).substring(with: match.range)
                
                // Convert the hex substring into a numeric byte value.
                if let byte = UInt8(byteString, radix: 16) {
                    // Append the byte to the data object being constructed.
                    data.append(byte)
                }
            }
        }
        
        // If no bytes were parsed (the string contained no valid hex), return nil.
        guard data.count > 0 else { return nil }
        
        // Return the Data object constructed from the hex string.
        return data
    }
}

/// Extension of CharacterSet adding a custom set of whitespace, newline, and null characters.
extension CharacterSet {
    /// A CharacterSet containing whitespace, newline, and null ("\0") characters.
    /// Use this set to trim or filter out such characters from strings.
    static let whitespacesNewlinesAndNulls = CharacterSet.whitespacesAndNewlines.union(CharacterSet(["\0"]))
}
