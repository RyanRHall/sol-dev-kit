{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.lcov
    pkgs.lintspec
    pkgs.bun
    pkgs.slither-analyzer
    pkgs.echidna
  ];

  # https://devenv.sh/languages/
  languages.solidity.enable = true;
  languages.solidity.foundry.enable = true;

  languages.python.enable = true;
  languages.python.venv.enable = true;
  languages.python.venv.requirements = ''
    halmos
  '';

  # https://devenv.sh/scripts/
  scripts.solhint.exec = ''
    bun solhint
  '';

  enterShell = ''
    bun install
    pip install git+https://github.com/RareSkills/vertigo-rs.git -q
  '';

  # These tests should match the CI workflows
  enterTest = ''
    echo "Running Foundry Tests"
    forge test -v

    echo "Checking Format"
    forge fmt --check

    echo "Running Foundry Linter"
    forge lint

    echo "Running Solhint"
    bun solhint 'src/**/*.sol'

    echo "Running Lintspec"
    lintspec

    echo "Running Slither"
    slither .
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
