{
  self,
  inputs,
  outputs,
  stateVersion,
  ...
}:
{
  # Helper function for generating host configs
  mkHost =
    {
      hostname,
      desktop ? null,
      pkgsInput ? inputs.nixpkgs,
    }:
    pkgsInput.lib.nixosSystem {
      specialArgs = {
        inherit
          self
          inputs
          outputs
          stateVersion
          hostname
          desktop
          ;
      };
      modules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        ../host
      ];
    };

    forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
  ];
}
