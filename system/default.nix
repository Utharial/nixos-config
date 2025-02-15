{
  config,
  desktop,
  hostname,
  inputs,
  lib,
  modulesPath,
  outputs,
  stateVersion,
  username,
  ...
}: 
{

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      (./. + "/x86_64-linux/${hostname}/base/configuration.nix")
    ];
    #++ lib.optional (builtins.pathExists (./. + "/${hostname}/extra.nix")) ./${hostname}/extra.nix
    # Include desktop config if a desktop is defined
    #++ lib.optional (builtins.isString desktop) ./common/desktop;

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    #registry = lib.mkForce (lib.mapAttrs (_: value: { flake = value; }) inputs);

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
#    nixPath = lib.mkForce (
 #     lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry
  #  );

    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  system = {
    inherit stateVersion;
  };
}
