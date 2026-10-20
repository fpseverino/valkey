# ``VaporValkey``

This library provides Valkey/Redis drivers for Vapor caching and sessions, based on valkey-swift.

## Overview

Create a Valkey client or connection (any type conforming to [`ValkeyClientProtocol`](https://swiftpackageindex.com/valkey-io/valkey-swift/documentation/valkey/valkeyclientprotocol)) and use it to configure the application's cache and session driver:

```swift
import Logging
import Valkey
import Vapor
import VaporValkey

let valkeyClient = ValkeyClient(.hostname("localhost"), logger: .current)

let app = try Application(
    services: .init(
        cache: .provided(ValkeyCache(client: valkeyClient)),
        sessionDriver: .provided(ValkeySessions(client: valkeyClient))
    )
)

// If you're using a connection pool backed client, remember to run it
app.addService(valkeyClient)
```

For more information about Vapor's session system, see [Sessions](https://docs.vapor.codes/advanced/sessions/).

## Topics

### Sessions

- ``ValkeySessions``

### Cache

- ``ValkeyCache``
