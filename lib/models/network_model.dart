class NetworkInterface {
  NetworkInterface({
    required this.description,
    required this.networkInterfaceInterface,
    required this.macAddress,
    required this.ipAddresses,
    required this.gateway,
    required this.domain,
    required this.dhcpServer,
    required this.dnsServers,
    required this.label,
  });

  final String? description;
  final String? networkInterfaceInterface;
  final String? macAddress;
  final List<String> ipAddresses;
  final String? gateway;
  final String? domain;
  final String? dhcpServer;
  final String? dnsServers;
  final String? label;

  NetworkInterface copyWith({
    String? description,
    String? networkInterfaceInterface,
    String? macAddress,
    List<String>? ipAddresses,
    String? gateway,
    String? domain,
    String? dhcpServer,
    String? dnsServers,
    String? label,
  }) {
    return NetworkInterface(
      description: description ?? this.description,
      networkInterfaceInterface:
          networkInterfaceInterface ?? this.networkInterfaceInterface,
      macAddress: macAddress ?? this.macAddress,
      ipAddresses: ipAddresses ?? this.ipAddresses,
      gateway: gateway ?? this.gateway,
      domain: domain ?? this.domain,
      dhcpServer: dhcpServer ?? this.dhcpServer,
      dnsServers: dnsServers ?? this.dnsServers,
      label: label ?? this.label,
    );
  }

  factory NetworkInterface.fromJson(Map<String, dynamic> json) {
    return NetworkInterface(
      description: json["description"],
      networkInterfaceInterface: json["interface"],
      macAddress: json["mac_address"],
      ipAddresses: json["ip_addresses"] == null
          ? []
          : List<String>.from(json["ip_addresses"]!.map((x) => x)),
      gateway: json["gateway"],
      domain: json["domain"],
      dhcpServer: json["dhcp_server"],
      dnsServers: json["dns_servers"],
      label: json["label"],
    );
  }

  Map<String, dynamic> toJson() => {
    "description": description,
    "interface": networkInterfaceInterface,
    "mac_address": macAddress,
    "ip_addresses": ipAddresses.map((x) => x).toList(),
    "gateway": gateway,
    "domain": domain,
    "dhcp_server": dhcpServer,
    "dns_servers": dnsServers,
    "label": label,
  };
}
