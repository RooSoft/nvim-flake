{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
    nixfmt = {
      url = "github:piegamesde/nixfmt?ref=rfc101-style";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , neovim-src
    , nixfmt
    , ...
    }:
    let
      inherit (nixpkgs) lib;
      #
      # Funni helper function
      #
      withSystem =
        f:
        lib.fold lib.recursiveUpdate { } (
          map f [
            "x86_64-linux"
            "x86_64-darwin"
            "aarch64-linux"
            "aarch64-darwin"
          ]
        );
    in
    withSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        #
        # Linter and formatter, run with "nix fmt"
        # You can use nixfmt or nixpkgs-fmt instead of alejandra if you wish
        #
        formatter.${system} = pkgs.writeShellApplication {
          name = "lint";
          runtimeInputs = [
            (pkgs.nixfmt.overrideAttrs {
              version = "0.6.0-${nixfmt.shortRev}";

              src = nixfmt;
            })
            pkgs.deadnix
            pkgs.statix
            pkgs.fd
            pkgs.stylua
          ];
          text = ''
            fd '.*\.nix' . -x statix fix -- {} \;
            fd '.*\.nix' . -X deadnix -e -- {} \; -X nixfmt {} \;
            fd '.*\.lua' . -X stylua --indent-type Spaces --indent-width 2 {} \;
          '';
        };
        #
        # Overlay which only provides neovim
        #
        overlays.default = final: _: removeAttrs self.packages.${final.system} [ "default" ];
        #
        # Dev shell which provides the final neovim package and npins
        #
        devShells.${system}.default = pkgs.mkShell {
          packages = [
            self.packages.${system}.default
            pkgs.npins
          ];
        };

        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.neovim ];
        };

        packages.${system} = {
          default = self.packages.${system}.neovim;

          buildInputs = [ pkgs.neovim ];

          neovim =
            let
              neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
                plugins =
                  [
                    #
                    # Add plugins from nixpkgs here
                    #
                    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
                    pkgs.vimPlugins.kanagawa-nvim
                    pkgs.vimPlugins.tokyonight-nvim
                    pkgs.vimPlugins.comment-nvim
                    pkgs.vimPlugins.vim-pathogen
                  ]
                  ++ lib.mapAttrsToList
                    (
                      #
                      # This generates plugins from npins sources
                      #
                      name: src: (pkgs.vimUtils.buildVimPlugin { inherit name src; })
                    )
                    (import ./npins);
                #
                # These options are self explanatory
                #
                withPython3 = true;
                extraPython3Packages = _: [ ];
                withRuby = true;
                viAlias = false;
                vimAlias = true;
                #
                # Use the string generated in ./lua/default.nix for init.vim
                #
                customRC = import ./lua;
              };
              wrapperArgs =
                let
                  path = lib.makeBinPath [
                    #
                    # Runtime dependencies
                    #
                    pkgs.deadnix
                    pkgs.statix
                    pkgs.nil
                    pkgs.ripgrep
                    pkgs.fd
                    pkgs.lua-language-server
                    pkgs.stylua
                  ];
                in
                neovimConfig.wrapperArgs
                ++ [
                  "--prefix"
                  "PATH"
                  ":"
                  path
                ];
            in
            pkgs.wrapNeovimUnstable
              (pkgs.neovim-unwrapped.overrideAttrs (
                _: {
                  #
                  # Use neovim nightly
                  #
                  src = neovim-src;
                  version = neovim-src.shortRev or "dirty";
                  patches = [ ];
                  preConfigure = ''
                    sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
                  '';
                }
              ))
              (neovimConfig // { inherit wrapperArgs; });
        };
      }
    );
}
