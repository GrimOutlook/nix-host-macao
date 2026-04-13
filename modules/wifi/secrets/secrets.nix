let
  macao = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFs4I3Fka4jnQIW2N3e74+3LigPwblqHx3S73UHUgsp";
in
{
  "wifi.age".publicKeys = [ macao ];
}
