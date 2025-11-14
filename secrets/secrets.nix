let
  qraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUnZQFo+GMqhnNUfzExwZvZRPmOy8+bZyABQCsSyqT0";
  wraspi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYowJeGWog8ViplIju1naCrRdRzmerqCY3Eq1T2N9a8";
  mixer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBWCTtXHe/Zpr9qyWhDVY+pKX/b/VA3DFiUrDpOQFCl4";
  toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwYNiDUMF/rOBh929JDGXtr5371osQkgHAa7pmiuTwr";
  other = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIR/Dqd+UXeEQovChEHgDhIIaXcrpa+i2/KwECTbkp5q";
  github-runner = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtY5AcmCumRiR3YDnMfNU7Ye1EPTKO6Lf9V0jphOCay";
in
{
  "risaro.la.age".publicKeys = [ qraspi wraspi toaster other ];
  "somefile.zip.age".publicKeys = [ mixer toaster other ];
  "github-runner-ncc-1.age".publicKeys = [ github-runner toaster other ];
}
