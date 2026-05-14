{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
    pkgs.lintspec
    pkgs.slither-analyzer
    pkgs.echidna
    pkgs.glow
  ];

  languages.solidity.enable = true;
  languages.solidity.foundry.enable = true;

  languages.javascript.enable = true;
  languages.javascript.bun.enable = true;
  languages.javascript.bun.install.enable = true;

  languages.python.enable = true;
  languages.python.uv.enable = true;
  languages.python.uv.sync.enable = true;
  languages.python.venv.enable = true;

  tasks."devenv:solidity:soldeer" = {
    exec = "forge soldeer install";
    before = [ "devenv:enterShell" ];
  };

  scripts.aderyn-check.exec = "aderyn --stdout | glow";
}
