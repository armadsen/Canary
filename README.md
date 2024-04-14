# Pigeon

Pigeon is a Swift package that makes it easy to split incoming data into packets. This is useful when communicating using protocols that use raw streams of data that are not necessarily received a single complete packet a time. 
Some examples:

- Communicating with embedded devices
- Communicating across raw network sockets
- Using Bluetooth LE to transmit packets larger than 251 bytes (or less for older protocol versions)

The API for Pigeon was inspired by the [packet parsing API](https://github.com/armadsen/ORSSerialPort/wiki/Packet-Parsing-API) included in [ORSSerialPort](https://github.com/armadsen/ORSSerialPort).

This package is very much a work in progress, and should be considered pre-alpha right now. However, contributions are always welcome.
