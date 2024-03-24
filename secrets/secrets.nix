let
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE root@smart-blender";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ system1 ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ system1 ];
}
