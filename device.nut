//===========================
// SETUP
//===========================

#include "ConnectionManager.class.nut"
#include "UartLogger.class.nut"
#include "WifiQueue.class.nut"

wifiList <- [
	{"ssid": "test1", "pw": "test1"},
	{"ssid": "test2", "pw": "test2"},
	{"ssid": "IndepStudiosUP", "pw": "test3"}
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
wq <- WifiQueue(cm, null /* wifiList */, logs);

imp.onidle(function() {
	wq.connect();
});

