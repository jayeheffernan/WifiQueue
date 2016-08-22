# WifiQueue 1.0.0

The WifiQueue class is an Electric Imp device side library to allow the device to attempt to connect to a supplied list of WiFi networks.

**NOTE:** Requires ConnectionManager v1.1.1.
Always use the `connect` and `disconnect` functions from this class instead of the corresponding functions in ConnectionManager or `server.connect` and `server.disconnect`.

## Class Usage

### Constructor: WifiQueue(*cm[, wifiList[,  logs]]*)

The WifiQueue class is instantiated with a ConnectionManager object and two optional parameters, wifiList and logs.
**NOTE:** The WifiQueue class requires the ConnectionManager's `retry` parameter to be set to `false` as seen below.

| key               | default             | notes |
| ----------------- | ------------------- | ----- |
| cm | N/A | A ConnectionManager object |
| wifiList | `NULL` | An array of objects with `ssid` and `pw` parameters |
| logs | `NULL` | An object to write logs to. Use the UartLogger class if you need offline logs |

```squirrel
wifiList <- [
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

wq <- WifiQueue(cm, wifiList, logs);
```

## Class Methods

# setLogs(logs)

This function allows the user to change the logs object.

# setWifiList(wifiList)

This function allows the user to change the list of networks. When the device next attempts to connect it will start from the beginning of the list.

## connect()

This function triggers the device to start trying to connect. It will first attempt to connect to the network it was blinked up to and if that
fails it will cycle through the list of networks provided until it succeeds.

Will return `false` if it is already trying to connect and `true` if it is already connected.
If the current ssid is empty, the onFail handler will immediately be called.

```squirrel
wq.connect();
```

## disconnect()

This function disconnects the device from WiFi. The `didDisconnect()` function will be triggered.

```squirrel
wq.disconnect();
```

## onConnect(*callback*)

This function sets a callback to be trigger whenever the device connects.

```squirrel
wq.onConnect(function() {
	// Do something here...
})
```

## onFail(*callback*)

This function sets a callback to be trigger whenever the device attempts and fails to connect. The failed SSID is passed to the function

```squirrel
wq.onFail(function(ssid) {
	// Do something here...
})
```

## onDisconnect(*callback*)

This function sets a callback to be trigger whenever the device disconnects. An `expected` parameter is passed to the function.

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
