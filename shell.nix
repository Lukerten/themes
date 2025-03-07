{
  pkgs ? (let
    inherit (builtins) fetchTree fromJSON readFile;
    inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs;
  in
    import (fetchTree nixpkgs.locked) {}),
}: let
  import_album = pkgs.writeShellScriptBin "import_album" ./wallpapers/image_import_album.sh;
  import_single = pkgs.writeShellScriptBin "import_single" ./wallpapers/image_import_album.sh;
  list_images = pkgs.writeShellScriptBin "list_images" ./wallpapers/image_import_album.sh;
  preview_image = pkgs.writeShellScriptBin "preview_image" ./wallpapers/image_import_album.sh;
in
  pkgs.mkShell {
    hardeningDisable = ["all"];
    name = "theme-dev-shell";
    buildInputs = [
      import_album
      import_single
      list_images
      preview_image
    ];
    shellHook = "";
  }
