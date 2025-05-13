{
  pkgs ? (let
    inherit (builtins) fetchTree fromJSON readFile;
    inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs;
  in
    import (fetchTree nixpkgs.locked) {}),
}:
pkgs.mkShell {
  hardeningDisable = ["all"];
  name = "themes";
  buildInputs = [
  ];
  shellHook = ''
    printf "\e[1;32m%s\e[0m\n" "Happy Hacking!";
    printf ""
    printf "\e[1;32m%s\e[0m\n" "To update the wallpaper library, run \`updateLibrary.sh\`";
  '';
}
