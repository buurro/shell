let
  blender = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE";
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
  mixer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtpzDFHytf4zXusT1YfNb6sdIGunR4uZdhjgo24u3W0";
  toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwYNiDUMF/rOBh929JDGXtr5371osQkgHAa7pmiuTwr";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ blender ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ blender ];
  "risaro.la.age".publicKeys = [ blender qraspi ];
  "mixer-vpn-conf.age".publicKeys = [ toaster mixer ];
}
