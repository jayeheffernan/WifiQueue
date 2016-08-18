//===========================
// SETUP
//===========================

#include "ConnectionManager.class.nut"
#include "UartLogger.class.nut"
#include "WifiQueue.class.nut"

wifiList <- [
	{"ssid": "test1", "pw": "test1"},
	{"ssid": "test2", "pw": "test2"},
	{"ssid": "IndepStudiosUP", "pw": "lightmyfiretwenty"}
];

//===========================
// PROGRAM CODE
//===========================

uart <- hardware.uart12;
uart.configure(9600, 8, PARITY_NONE, 1, NO_CTSRTS);
logs <- UartLogger(uart);

logs.log("I'm alive");

imp.wakeup(5, function() {
	wq <- WifiQueue(wifiList);
	wq.disconnect();
	wq.init();
	wq.connect();
}.bindenv(this));
