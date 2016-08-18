//===========================
// SETUP
//===========================



//===========================
// CLASS
//===========================

class WifiQueue {

	// Variables
	_wifiList = null;
	_cm = null;
	_connecting = false;
	_currentNetwork = null;

	constructor(wifiList) {

		_wifiList = wifiList;
		_cm = ConnectionManager({
			"blinkupBehavior": ConnectionManager.BLINK_NEVER,
			"startDisconnected": false,
			"retry": false,
			"stayConnected": false
		});

	}

	//-----------------------
	function disconnect() {
		_cm.disconnect();
	}

	//-----------------------
	function init() {

		// Callback to run when device connects
		_cm.onConnect(function() {

			_connecting = false;
			logs.write("Successfully connected to network " + _currentNetwork + "\r\n");

		}.bindenv(this));

		// Callback to run when device attempts and fails to connect
		_cm.onFail(function() {

			_connecting = false;

			logs.write("Could not connect to network " + _currentNetwork + "\r\n");

			if (_currentNetwork == (_wifiList.len() - 1)) {
				logs.write("Failed to connect to any network\r\n");
				logs.write("Connecting to IndepStudiosUP...")
				imp.setwificonfiguration("IndepStudiosUP", "lightmyfiretwenty");
				return;
			}

			_currentNetwork++;
			connect();

		}.bindenv(this));

	}

	//-----------------------
	// Attempt to connect to each network in the list until the first successful connection
	function connect() {

		if (_cm.isConnected()) {
			logs.write("Already connected\r\n");
			return;
		}
		if (_connecting == true) {
			logs.write("Already trying to connect\r\n");
			return;
		}
		_currentNetwork = _currentNetwork || 0; // CHECK THIS!!!!!!!
		_connecting = true;

		local network = _wifiList[_currentNetwork];

		imp.setwificonfiguration(network.ssid, network.pw);
		logs.write("Trying to connect...\r\n");
		_cm.connect();

	}

}
