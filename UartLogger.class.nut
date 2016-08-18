class UartLogger {

	// Variables
	_uart = null;

	constructor(uart) {
		_uart = uart;
	}

	//-----------------------
	function log(msg) {

		local date = date();
		local dateStr = format("%02d-%02d-%02d %02d:%02d:%02d", date.year, (date.month + 1), date.day, date.hour, date.min, date.sec);
		_uart.write(dateStr + "    " + msg + "\r\n");
		server.log(msg);

	}

	//-----------------------
	function error(msg) {
		local date = date();
		local dateStr = format("%02d-%02d-%02d %02d:%02d:%02d", date.year, (date.month + 1), date.day, date.hour, date.min, date.sec);
		_uart.write(dateStr + " [ERROR]    " + msg + "\r\n");
		server.error(msg);
	}

}
