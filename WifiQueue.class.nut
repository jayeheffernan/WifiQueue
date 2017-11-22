// Copyright (c) 2016 Mystic Pants Pty Ltd
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

const WIFIQUEUE_HIDDEN = 0x01;
const WIFIQUEUE_OPEN   = 0x02;

class WifiQueue {
    static version = [3, 0, 0];

    // Connection manager instance
    _cm = null;
    // List of wifi networks to try
    _wifis = null;
    // Whether we are currently trying to connect to a network
    _connecting = false;
    // Whether we should try networks that are not visible (because they may be hidden)
    _hidden = null;
    // Whether we should try open wifi networks (that are not in the list we were given)
    _open = null;
    // Whether we have scanned for open wifi networks to initiate warDriving yet
    _warDriving = false;

    // Callbacks
    _onFail = null;
    _onConnect = null;
    _onDisconnect = null;

    // -----------------------
    // `cm` is a connection manager instance
    // `wifis` is an [ { ssid, pw } ]
    // `flags` is a bit-array of boolean options`
    // `logger` is a logger object with `.log()` and `.error()` methods
    constructor(cm, flags = null, logger = server) {
        _cm = cm;

        // Process options
        flags = flags || 0;
        _hidden = flags & WIFIQUEUE_HIDDEN;
        _open   = flags & WIFIQUEUE_OPEN;

        // Set ConnectionManager callbacks
        _cm.onConnect(_didConnect.bindenv(this));
        _cm.onTimeout(_didTimeout.bindenv(this));
        _cm.onDisconnect(_didDisconnect.bindenv(this));
    }

    // -----------------------
    // Attempt to connect to list of wifis
    //
    // Other methods of this class which call this method "recursively"
    // e.g. `.didTimeout()` will call method with `_reset == false` to
    // avoid resetting the wifi list each time.  When called from outside a
    // list of wifi networks should be passed in to initialize this
    // connecting attempt.
    function connect(wifis = null, _reset = true) {
        if (_reset) {
            // Cancel any in-progress wardriving
            _warDriving = false;

             // Copy the array because we will be mutating it, and we need to be the
            // only ones
            _wifis = clone(wifis || []);

            // Remove invalid entries
            for (local i = _wifis.len() - 1; i >= 0; i--) {
                local n = _wifis[i];
                if (!("ssid" in n && n.ssid.len() > 0 && "pw" in n)) {
                    logger.error("invalid wifi: " + i);
                    _wifis.remove(i);
                }
            }
        }

        if (_connecting) {
            return false;
        }

        if (_cm.isConnected()) {
            _didConnect();
            return true;
        }

        if (imp.getssid() != "") {
            _connecting = true;
            _cm.connect();
        } else {
            if (_onFail) _onFail();
        }
    }

    // -----------------------
    function disconnect() {
        _connecting = false;
        _cm.disconnect();
    }


    // -----------------------
    // Set the onConnect callback
    function onConnect(callback) {
        _onConnect = callback;
        return this;
    }


    // -----------------------
    // Set the onFail callback
    //
    // This will run when WifiQueue fails to connect to any network
    function onFail(callback) {
        _onFail = callback;
        return this;
    }


    // -----------------------
    function onDisconnect(callback) {
        _onDisconnect = callback;
        return this;
    }

    /*------------- PRIVATE FUNCTIONS -------------*/

    // -----------------------
    // Callback to run when device connects
    function _didConnect() {
        _connecting = false;
        logger.log("Connected to network: " + imp.getssid());
        if (_onConnect) _onConnect();
    }


    // -----------------------
    // Callback to run when device times out connecting to a network
    function _didTimeout() {
        _connecting = false;
        logger.log("Could not connect to network: " + imp.getssid());

        // Select the next network to try
        local next = _pop();

        if (next) {
            // Configure the Imp to use the network
            imp.setwificonfiguration(next.ssid, next.pw);

            // Try to connect
            connect(null, false);
        } else {
            // No next network to try, we're all out of ideas
            return _onFail();
        }
    }


    // -----------------------
    // Callback to run when device disconnects
    function _didDisconnect(expected) {
        _connecting = false;
        if (_onDisconnect) _onDisconnect(expected);
        if (!expected) {
            // Try again
            connect(null, false);
        }
    }


    // -----------------------
    // Select and "pop" the next network off the list of networks to try
    function _pop() {
        // Scan the area
        local visible = imp.scanwifinetworks();

        // Ideally we can find a know network that is also visible...
        foreach(ind, known in _wifis) {
            foreach (seen in visible) {
                if (known.ssid == seen.ssid) {
                    // We know about this network, and it is visible.  Sounds
                    // promising!
                    return _wifis.remove(ind);
                }
            }
        }

        // No visible networks are known...
        if (_wifis.len() && _hidden && !_warDriving) {
            // We have known networks and we are supposed to try them all.
            // Just grab the first one.  Note that if we are warDriving
            // already, then we know there aren't any hidden networks in the
            // list anymore, so we won't go down this path
            return _wifis.remove(0);
        } else if (_open && !_warDriving) {
            // We are done with all our known networks, let's have a go at wardriving!
            // Reset our "known" list of wifis to the list of all open visible networks.
            _wifis = visible.filter(@(nw) nw.open).map(@(nw) { "ssid": nw.ssid, "pw": "" });
            if (_wifis.len()) {
                // Try the first one
                return _wifis.remove(0);
            }
        }

        // No networks found to try, give up
        return null;
    }

}
