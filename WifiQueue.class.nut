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
			logs.log("Successfully connected to network " + _wifiList[_currentNetwork].ssid);

		}.bindenv(this));

		// Callback to run when device attempts and fails to connect
		_cm.onFail(function() {

			_connecting = false;

			logs.log("Could not connect to network " + _wifiList[_currentNetwork].ssid);

			if (_currentNetwork == (_wifiList.len() - 1)) {
				logs.error("Failed to connect to any network");
				logs.log("Connecting to IndepStudiosUP...")
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
			logs.log("Already connected");
			return;
		}
		if (_connecting == true) {
			logs.log("Already trying to connect");
			return;
		}
		_currentNetwork = _currentNetwork || 0; // CHECK THIS!!!!!!!
		_connecting = true;

		local network = _wifiList[_currentNetwork];

		imp.setwificonfiguration(network.ssid, network.pw);
		logs.log("Trying to connect...");
		_cm.connect();

	}

}
