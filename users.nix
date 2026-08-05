let
  marco = {
    email = "marcoburro98@gmail.com";
    fullName = "Marco Burro";
    ssh.publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvHXYgTNpt43B9fjWH9lHCiJCXlLTn/9JZXMhOvSdCi" # keep this one as first element
    ];
  };
in {
  inherit marco;
  dev = marco;
}
