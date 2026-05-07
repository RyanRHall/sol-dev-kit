{ pkgs, lib, config, inputs, ... }:

{
  packages = [
    pkgs.git
    pkgs.lintspec
    pkgs.slither-analyzer
    pkgs.echidna
  ];

  languages.solidity.enable = true;
  languages.solidity.foundry.enable = true;

  languages.javascript.bun.enable = true;
  languages.javascript.bun.install.enable = true;

  languages.python.enable = true;
  languages.python.venv.enable = true;
  languages.python.venv.requirements = ./requirements.txt;
}
