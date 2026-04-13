{
  config,
  ...
}:
{
  age.secrets.wifi = {
    file = ./secrets/wifi.age;
    owner = "root";
    mode = "0400";
  };
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ config.age.secrets.wifi.path ];
      profiles = {
        my-wifi = {
          connection = {
            id = "MLH";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "MLH";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$NM_WIFI_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
}
