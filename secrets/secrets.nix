let
  blender = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE";
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
  mixer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhOcZVqmRV4SLWJQX73zb6j+e9V3bPlHaTyovmNXioJ";
  toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwYNiDUMF/rOBh929JDGXtr5371osQkgHAa7pmiuTwr";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ blender ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ blender ];
  "risaro.la.age".publicKeys = [ blender qraspi ];
  "mixer-vpn-conf.age".publicKeys = [ toaster mixer ];
}
