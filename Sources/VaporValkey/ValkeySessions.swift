import NIOCore
public import Valkey
public import Vapor

#if canImport(FoundationEssentials)
public import FoundationEssentials
import NIOFoundationEssentialsCompat
#else
public import Foundation
import NIOFoundationCompat
#endif

/// A session driver for Vapor that uses Valkey as the backend.
public struct ValkeySessions: SessionDriver {
    private let client: any ValkeyClientProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Creates a new instance of ``ValkeySessions`` with the given Valkey client, JSON decoder, and JSON encoder.
    ///
    /// - Parameters:
    ///   - client: The Valkey client or connection to use for session operations.
    ///   - decoder: The JSON decoder to use for decoding session data.
    ///   - encoder: The JSON encoder to use for encoding session data.
    public init(client: any ValkeyClientProtocol, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.client = client
        self.decoder = decoder
        self.encoder = encoder
    }

    public func createSession(_ data: SessionData, for request: Request) async throws -> SessionID {
        let sessionID = Self.generateID()
        let key = Self.makeKey(sessionID: sessionID)

        try await self.client.set(.init(key), value: self.encoder.encode(data))
        return sessionID
    }

    public func readSession(_ sessionID: SessionID, for request: Request) async throws -> SessionData? {
        try await self.client.get(.init(Self.makeKey(sessionID: sessionID))).map { result in
            try self.decoder.decode(SessionData.self, from: ByteBuffer(result))
        }
    }

    public func updateSession(_ sessionID: SessionID, to data: SessionData, for request: Request) async throws -> SessionID {
        try await self.client.set(.init(Self.makeKey(sessionID: sessionID)), value: self.encoder.encode(data))
        return sessionID
    }

    public func deleteSession(_ sessionID: SessionID, for request: Request) async throws {
        try await self.client.del(keys: [.init(Self.makeKey(sessionID: sessionID))])
    }

    private static func generateID() -> SessionID {
        .init(string: [UInt8].random(count: 32).base64String())
    }

    private static func makeKey(sessionID: SessionID) -> String {
        "vvs-\(sessionID.string)"
    }
}
