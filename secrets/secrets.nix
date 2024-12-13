let
  blender = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE";
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
  mixer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWCTtXHe/Zpr9qyWhDVY+pKX/b/VA3DFiUrDpOQFCl4";
  toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwYNiDUMF/rOBh929JDGXtr5371osQkgHAa7pmiuTwr";
  other = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIR/Dqd+UXeEQovChEHgDhIIaXcrpa+i2/KwECTbkp5q";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ blender ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ blender ];
  "risaro.la.age".publicKeys = [ qraspi toaster other ];
  "somefile.zip.age".publicKeys = [ mixer toaster other ];
}
