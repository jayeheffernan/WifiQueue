
// Copyright (c) 2016 Mystic Pants Pty Ltd
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

class WifiQueue {
	static version = [1,0,0];

	// Variables
	_cm = null;
	_wifiList = null;
	_connecting = false;
	_currentNetwork = null;
	_warDriving = false;

	_onFail = null;
	_onConnect = null;
	_onDisconnect = null;
	_logs = null;

	constructor(cm, wifiList = null, logs = null) {

		_cm = cm;
		_wifiList = wifiList;
		_logs = logs || server;

		if (_wifiList == null) {
			_warDriving = true;
		} else {
			assert(_wifiList.len() > 0);
		}

		_cm.onConnect(didConnect.bindenv(this));
		_cm.onFail(didFail.bindenv(this));
		_cm.onDisconnect(didDisconnect.bindenv(this));
	}

	//-----------------------
	function setLogs(logs) {
		_logs = logs;
	}

	//-----------------------
	function setWifiList(wifiList) {
		_wifiList = wifiList;
		_currentNetwork = null;
	}

	//-----------------------
	function isConnected() {
		_cm.isConnected();
	}

	//-----------------------
	// Attempt to connect to each network in the list until the first successful connection
	function connect() {

		if (_connecting) {
			_logs.log("Already trying to connect");
			return false;
		}

		if (_cm.isConnected()) {
			didConnect();
			return true;
		}

		if (imp.getssid() != "") {
			_logs.log("Trying to connect to: " + imp.getssid());
			_connecting = true;
			_cm.connect();
		} else {
			if (_onFail) _onFail();
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

	/*------------- PRIVATE FUNCTIONS -------------*/

	//-----------------------
	// Callback to run when device connects
	function didConnect() {

		_connecting = false;
		_logs.log("Successfully connected to network: " + imp.getssid());

		if (_onConnect) _onConnect();
	}

	//-----------------------
	// Callback to run when device attempts and fails to connect
	function didFail() {

		_connecting = false;
		_logs.log("Could not connect to network: " + imp.getssid());

		if (_warDriving) {
			if (_wifiList == null || _wifiList.len() == 0 || _currentNetwork == (_wifiList.len() - 1)) {
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
		} else if (_currentNetwork == (_wifiList.len() - 1)) {
			_logs.error("Failed to connect to any network");
		}

		local oldSsid = _wifiList[_currentNetwork].ssid;

		// Try the next network
		if (_wifiList.len() > 0) {
			_currentNetwork = _currentNetwork == null ? 0 : (_currentNetwork + 1) % _wifiList.len();
			local network = _wifiList[_currentNetwork];
			if ("ssid" in network && network.ssid.len() > 0 && "pw" in network) {
				imp.setwificonfiguration(network.ssid, network.pw);
			} else {
				_logs.error("Skipping invalid wifi list entry " + _currentNetwork);
			}
		} else {
			_logs.error("No networks to try");
		}

		// Throw the event
		if (_onFail) _onFail(oldSsid);
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
