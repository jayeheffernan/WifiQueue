# WifiQueue 3.0.0

The WifiQueue class is an Electric Imp device side library to allow the device to attempt to connect to a supplied list of WiFi networks.

**NOTE:** Requires ConnectionManager v1.1.1.
Always use the `connect` and `disconnect` functions from this class instead of the corresponding functions in ConnectionManager or `server.connect` and `server.disconnect`.

## Class Usage

### Constructor: WifiQueue(*cm[, wifiList[,  flags[, logger]]]*)

The WifiQueue class is instantiated with a ConnectionManager object and two optional parameters, wifiList and logs.

**NOTE:** The WifiQueue class requires the ConnectionManager's `retry` parameter to be set to `false`, as seen below.

| key               | default             | notes                                                           |
| ----------------- | ------------------- | -----                                                           |
| cm                | N/A                 | A ConnectionManager object                                      |
| wifiList          | `NULL`              | An array of objects with `ssid` and `pw` parameters             |
| flags             | `NULL`              | A bit array of binary options that control connection behaviour |

```squirrel
wifis <- [
	{"ssid": "test1", "pw": "password"},
	{"ssid": "test2", "pw": "password"},
	{"ssid": "test3", "pw": "password"}
]

cm <- ConnectionManager({
	"blinkupBehavior": ConnectionManager.BLINK_ON_DISCONNECT,
	"startDisconnected": false,
	"retry": false,
	"stayConnected": false
});
uart <- hardware.uart12;
logs <- UartLogger(uart);

logger <- server;

WifiQueue(cm, wifis, WIFIQUEUE_HIDDEN | WIFIQUEUE_OPEN, logger)
	.onConnect(function() {
		logger.log("WifiQueue connected to " + imp.getssid());
	})
	.onFail(function() {
		logger.error("WifiQueue failed to connect");
	})
	.connect();
```

## Flags

Flags are boolean options passed as the 3rd argument to the constructor.  Multiple flags should be "added"/"stacked" with the binary "or" operator, `|`.  All flags are off/`false` by default.

### WIFIQUEUE\_HIDDEN

This flag indicates whether any wifis listed in `wifiList` might be hidden.  If set, WifiQueue will try all networks in `wifiList` regardless of visibility.

### WIFIQUEUE\_OPEN

This flag indicates whether WifiQueue should try to connect to an visible
networks that are open.

## Connection Flow

1. Try to connect to the currently configured network.  This should normally be the last successfully configured network, and should have a high success rate if the device doesn't move around too much.
2. Try to connect to any visible, known networks.  Pick networks closer to the front of `wifiList` first if there are multiple candidates.
3. If WIFIQUEUE\_HIDDEN is set, try to connect to any other networks remaining in `wifiList`.
4. If WIFIQUEUE\_OPEN is set, call `imp.scanwifinetworks()` once to get a list of visible, open networks.  Try to connect to each in turn, as long as it remains visible at the time of attempting to connect.
5. If we have still not managed to connect to any network, call the `onFail` callback.

## Class Methods

# setLogs(logs)

This function allows the user to change the logs object.

# setWifiList(wifiList)

This function allows the user to change the list of networks. When the device next attempts to connect it will start from the beginning of the list.

## connect()

Triggers the device to start trying to connect.

Will return `false` if it is already trying to connect and `true` if it is already connected.
If the current ssid is empty, the onFail handler will immediately be called.

```squirrel
wq.connect();
```

## disconnect()

Disconnects the device from WiFi. The `didDisconnect()` function will be triggered.

```squirrel
wq.disconnect();
```

## onConnect(*callback*)

Sets a callback to be trigger whenever the device connects.

```squirrel
wq.onConnect(function() {
	// Do something here...
})
```

## onFail(*callback*)

Sets a callback to be trigger whenever the device attempts and fails to connect. The failed SSID is passed to the function

```squirrel
wq.onFail(function() {
	// Do something here...
})
```

## onDisconnect(*callback*)

Sets a callback to be trigger whenever the device disconnects. An `expected` parameter is passed to the function.

```squirrel
wq.onDisconnect(function(expected) {
	if (expected) {
		// Do something here...
	} else {
		// Do something here...
	}
})
```

# License

The WifiQueue class is licensed under the [MIT License](https://github.com/mysticpants/WifiQueue/LICENSE)
