let
  blender = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE";
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ blender ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ blender ];
  "risaro.la.age".publicKeys = [ blender qraspi ];
}
