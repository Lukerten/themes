{pkgs, ...}: let
  inherit (pkgs) lib;
  generateColorscheme = name: source: let
    schemeTypes = ["content" "expressive" "fidelity" "fruit-salad" "monochrome" "neutral" "rainbow" "tonal-spot"];
    isHexColor = c: lib.isString c && (builtins.match "#([0-9a-fA-F]{3}){1,2}" c) != null;

    config = (pkgs.formats.toml {}).generate "config.toml" {
      templates = {};
      config = {
        custom_colors = {
          red = "#dd0000";
          orange = "#dd5522";
          yellow = "#dddd00";
          green = "#22dd22";
          cyan = "#22dddd";
          blue = "#2222dd";
          magenta = "#dd22dd";
        };
      };
    };

    # Get the actual image path from the source derivation
    # First check if the source is a hex color, then check if it's null,
    # otherwise construct the path to the image file
    imagePath =
      if (isHexColor source)
      then source
      else if source == null
      then "#000000" # Fallback to black when source is null
      else "${source}/${name}.${builtins.getAttr name (lib.importJSON ../wallpapers/list.json).ext}";
  in
    pkgs.runCommand "colorscheme-${name}" {
      # __contentAddressed = true;
      passthru = let
        drv = generateColorscheme name source;
      in {
        inherit schemeTypes;
        # Incurs IFD
        imported = lib.genAttrs schemeTypes (scheme: lib.importJSON "${drv}/${scheme}.json");
      };
    } ''
      mkdir "$out" -p
      for type in ${lib.concatStringsSep " " schemeTypes}; do
        ${pkgs.matugen}/bin/matugen ${
        if (isHexColor source)
        then "color hex"
        else "image"
      } --config ${config} -j hex -t "scheme-$type" "${imagePath}" > "$out/$type.json"
      done
    '';
in
  generateColorscheme
