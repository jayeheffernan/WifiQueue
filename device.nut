
// Copyright (c) 2016 Mystic Pants Pty Ltd
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

//===========================
// SETUP
//===========================

#include "ConnectionManager.class.nut"
#include "UartLogger.class.nut"
#include "WifiQueue.class.nut"

wifiList <- [
	{"ssid": "test1", "pw": "password"},
	{"ssid": "test2", "pw": "password"},
	{"ssid": "test3", "pw": "password"}
];

//===========================
// PROGRAM CODE
//===========================

cm <- ConnectionManager({
	"blinkupBehavior": ConnectionManager.BLINK_ON_DISCONNECT,
	"startDisconnected": false,
	"retry": false,
	"stayConnected": false
});

uart <- hardware.uart12;
logs <- UartLogger(uart);
wq <- WifiQueue(cm, wifiList, logs);

imp.onidle(function() {
	wq.connect();
});

