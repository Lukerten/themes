{pkgs}:
pkgs.lib.listToAttrs (map (wallpaper: {
  inherit (wallpaper) name;
  value = pkgs.runCommand "${wallpaper.name}.${wallpaper.ext}" {} ''
    cp ${./images}/${wallpaper.name}.${wallpaper.ext} $out
  '';
}) (pkgs.lib.importJSON ./list.json))
