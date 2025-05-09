{
  pkgs ? (let
    inherit (builtins) fetchTree fromJSON readFile;
    inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs;
  in
    import (fetchTree nixpkgs.locked) {}),
}: let
  importSingle = pkgs.writeShellScriptBin "importSingle" ./scripts/imageImportSingle.sh;
  listImages = pkgs.writeShellScriptBin "listImages" ./scripts/imageList.sh;
  previewImage = pkgs.writeShellScriptBin "previewImage" ./scripts/imagePreview.sh;
in
  pkgs.mkShell {
    hardeningDisable = ["all"];
    name = "theme-dev-shell";
    buildInputs = [
      importSingle
      listImages
      previewImage
    ];
    shellHook = "";
  }
