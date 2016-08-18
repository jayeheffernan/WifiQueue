
class WifiQueue {

	// Variables
	_cm = null;
	_wifiList = null;
	_connecting = false;
	_currentNetwork = null;

	_onFail = null;
	_onConnect = null;
	_onDisconnect = null;

	constructor(cm, wifiList = null, logs = null) {

		_cm = cm;
		_wifiList = wifiList;
		if (logs == null) logs = server;

		if (_wifiList != null) {
			assert(_wifiList.len() > 0);
		}

		_cm.onConnect(didConnect.bindenv(this));
		_cm.onFail(didFail.bindenv(this));
		_cm.onDisconnect(didDisconnect.bindenv(this));
	}


	//-----------------------
	// Attempt to connect to each network in the list until the first successful connection
	function connect() {

		if (_connecting) {
			logs.log("Already trying to connect");
			return false;
		}

		if (_cm.isConnected()) {
			didConnect();
			return true;
		}

		if (imp.getssid() != "") {
			logs.log("Trying to connect to: " + imp.getssid());
			_connecting = true;
			_cm.connect();
		} else {
			didFail();
		}

	}

	//-----------------------
	function disconnect() {
		_connecting = false;
		_cm.disconnect();
	}


	//-----------------------
	function onConnect(callback) {
		_onConnect = callback;
	}


	//-----------------------
	function onFail(callback) {
		_onFail = callback;
	}


	//-----------------------
	function onDisconnect(callback) {
		_onDisconnect = callback;
	}


	//-----------------------
	// Callback to run when device connects
	function didConnect() {

		_connecting = false;
		logs.log("Successfully connected to network: " + imp.getssid());

		if (_onConnect) _onConnect();
	}

	//-----------------------
	// Callback to run when device attempts and fails to connect
	function didFail() {

		_connecting = false;

		if (_wifiList == null || _currentNetwork == (_wifiList.len() - 1)) {
			// Time to wardrive!
			_wifiList = [];
			_currentNetwork = 0;
			local wifis = imp.scanwifinetworks();
			foreach (wifi in wifis) {
				if (wifi.open) {
					_wifiList.push({"ssid": wifi.ssid, "pw": ""})
				}
			}
		}

		if (_currentNetwork == (_wifiList.len() - 1)) {
			logs.error("Failed to connect to any network");
		} else {
			logs.log("Could not connect to network: " + imp.getssid());
		}

		// Try the next network
		_currentNetwork = _currentNetwork == null ? 0 : (_currentNetwork + 1) % _wifiList.len();
		local network = _wifiList[_currentNetwork];
		imp.setwificonfiguration(network.ssid, network.pw);

		// Throw the event
		if (_onFail) _onFail();
		if (!_connecting) {
			connect();
		}

	}


	//-----------------------
	function didDisconnect(expected) {
		_connecting = false;
		if (_onDisconnect) _onDisconnect(expected);
		if (!expected && !_connecting) {
			connect();
		}
	}

}
