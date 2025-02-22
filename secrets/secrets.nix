let
  blender = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJI74ZGq82VySA5AS5OCvafmhVwARDRlYow+mKXq6eIE";
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
  mixer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWCTtXHe/Zpr9qyWhDVY+pKX/b/VA3DFiUrDpOQFCl4";
  toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwYNiDUMF/rOBh929JDGXtr5371osQkgHAa7pmiuTwr";
  other = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIR/Dqd+UXeEQovChEHgDhIIaXcrpa+i2/KwECTbkp5q";
  github-runner = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtY5AcmCumRiR3YDnMfNU7Ye1EPTKO6Lf9V0jphOCay";
  wraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7U4YkBp3TyEZNETH0kFlyjTBTRPy74LqMs43TuwslO";
in
{
  "authelia.jwtSecretFile.age".publicKeys = [ blender ];
  "authelia.storageEncryptionKeyFile.age".publicKeys = [ blender ];
  "risaro.la.age".publicKeys = [ qraspi wraspi toaster other ];
  "somefile.zip.age".publicKeys = [ mixer toaster other ];
  "github-runner-ncc-1.age".publicKeys = [ github-runner toaster other ];
}
