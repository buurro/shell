{pkgs, ...}:
pkgs.stdenv.mkDerivation
{
  name = "timemachine";
  src = pkgs.fetchFromGitHub {
    owner = "cytopia";
    repo = "linux-timemachine";
    rev = "v1.3.2";
    sha256 = "k0FUVwgRFKiZkzmqLrAYxtxsAjcjTfR11SxTEffSUVo=";
  };

  # buildInputs = with pkgs; [
  #   rsync
  #   gnumake
  #   gnused
  #   coreutils
  #   bash
  # ];

  buildPhase = ''
    runHook preBuild

    substituteInPlace timemachine --replace "command -v rsync" "command -v ${pkgs.rsync}/bin/rsync"
    substituteInPlace timemachine --replace "cmd=\"rsync" "cmd=\"${pkgs.rsync}/bin/rsync"
    substituteInPlace timemachine --replace "grep" "${pkgs.gnugrep}/bin/grep"
    substituteInPlace timemachine --replace " sed " " ${pkgs.gnused}/bin/sed "
    substituteInPlace timemachine --replace " awk " " ${pkgs.busybox}/bin/awk "
    substituteInPlace timemachine --replace "mv " "${pkgs.busybox}/bin/mv "
    substituteInPlace timemachine --replace "ln " "${pkgs.busybox}/bin/ln "
    substituteInPlace timemachine --replace "ssh " "${pkgs.openssh}/bin/ssh "
    substituteInPlace timemachine --replace "\$(date" "\$(${pkgs.coreutils}/bin/date"
    substituteInPlace timemachine --replace "\$( date" "\$( ${pkgs.coreutils}/bin/date"

    substituteInPlace Makefile --replace "/bin/bash" "${pkgs.bash}/bin/bash"

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -t $out/bin timemachine
  '';
}
