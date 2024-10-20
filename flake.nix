{
  # Source: https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled

  description = "DM NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # This is the standard format for flake.nix.
  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    # NUR
    nur.url = github:nix-community/NUR;

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  # `outputs` are all the build result of the flake.
  #
  # A flake can have many use cases and different types of outputs.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, home-manager, agenix, nur, nixos-hardware, ... }@inputs:
    let
      inherit (self) outputs;

      systems = [
        "x86_64-linux"
      ];

      nurNoPkgs = import nur {
        nurpkgs = nixpkgs;
        pkgs = throw "nixpkgs eval";
      };

      forAllSystems = nixpkgs.lib.genAttrs systems;

    in
    rec {

      overlays = import ./overlays { inherit inputs; };

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pkgs pkgs);

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      nixosConfigurations = {
        # By default, NixOS will try to refer the nixosConfiguration with
        # its hostname, so the system named `crowntail` will use this one.
        # However, the configuration name can also be specified using:
        #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
        #
        # The `nixpkgs.lib.nixosSystem` function is used to build this
        # configuration, the following attribute set is its parameter.
        #
        # Run the following command in the flake's directory to
        # deploy this configuration on any NixOS system:
        #   sudo nixos-rebuild switch --flake .#crowntail
        "crowntail" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # The Nix module system can modularize configuration,
          # improving the maintainability of configuration.
          #
          # Each parameter in the `modules` is a Nix Module, and
          # there is a partial introduction to it in the nixpkgs manual:
          #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
          # It is said to be partial because the documentation is not
          # complete, only some simple introductions.
          # such is the current state of Nix documentation...
          #
          # A Nix Module can be an attribute set, or a function that
          # returns an attribute set. By default, if a Nix Module is a
          # function, this function have the following default parameters:
          #
          #  lib:     the nixpkgs function library, which provides many
          #             useful functions for operating Nix expressions:
          #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
          #  config:  all config options of the current flake, every useful
          #  options: all options defined in all NixOS Modules
          #             in the current flake
          #  pkgs:   a collection of all packages defined in nixpkgs,
          #            plus a set of functions related to packaging.
          #            you can assume its default value is
          #            `nixpkgs.legacyPackages."${system}"` for now.
          #            can be customed by `nixpkgs.pkgs` option
          #  modulesPath: the default path of nixpkgs's modules folder,
          #               used to import some extra modules from nixpkgs.
          #               this parameter is rarely used,
          #               you can ignore it for now.
          #
          # The default parameters mentioned above are automatically
          # generated by Nixpkgs. 
          # However, if you need to pass other non-default parameters
          # to the submodules, 
          # you'll have to manually configure these parameters using
          # `specialArgs`. 
          # you must use `specialArgs` by uncomment the following line:
          #
          # specialArgs = {...};  # pass custom arguments into all sub module.
          modules = [
            # Import the configuration.nix here, so that the
            # old configuration file can still take effect.
            # Note: configuration.nix itself is also a Nix Module,
            ./configuration.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dm = import ./users/dm.nix;
                users.iris = import ./users/iris.nix;

                extraSpecialArgs = {
                  inherit inputs outputs agenix nurNoPkgs;
                };
              };

            }
            {
              nix.settings.trusted-users = [ "root" "dm" ];
            }
            nixos-hardware.nixosModules.framework-11th-gen-intel
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
