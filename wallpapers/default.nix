{pkgs}: let
  # Create individual wallpaper derivations
  wallpaperAttrs = pkgs.lib.listToAttrs (map (wallpaper: {
    inherit (wallpaper) name;
    value =
      if wallpaper.path != null
      then
        pkgs.stdenv.mkDerivation {
          name = "wallpaper-${wallpaper.name}";
          src = ./. + "/${wallpaper.path}";
          dontUnpack = true;
          installPhase = ''
            mkdir -p $out
            cp $src $out/${wallpaper.name}
          '';
        }
      else
        # For null paths, create a minimal derivation with a fallback color
        pkgs.runCommand "wallpaper-${wallpaper.name}" {} ''
          mkdir -p $out
          # Create an empty file to prevent errors
          touch $out/${wallpaper.name}
        '';
  }) (pkgs.lib.importJSON ./list.json));

  # Create a single derivation that collects all individual wallpapers
  allWallpapers = pkgs.stdenv.mkDerivation {
    name = "wallpapers";
    dontUnpack = true;
    buildInputs = builtins.attrValues wallpaperAttrs;

    installPhase = ''
      mkdir -p $out
      for wallpaper in $buildInputs; do
        for file in $(find $wallpaper -type f); do
          cp -f $file $out/
        done
      done
    '';
  };
in
  # Return both the individual wallpapers and the combined collection
  wallpaperAttrs // {default = allWallpapers;}
