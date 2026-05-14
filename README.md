# Solidity Dev Kit

Built on [nix](https://nixos.org/) and [devenv](https://devenv.sh/), this repo has the following tools ready to use:

* [Foundry](https://www.getfoundry.sh/) - duh
* [Soldeer](https://soldeer.xyz/) - package management
* [Solhint](https://github.com/protofire/solhint) - linter
* [Slither](https://github.com/crytic/slither) - static analysis
* [Echidna](https://github.com/crytic/echidna) - fuzzer
* [Aderyn](https://github.com/Cyfrin/aderyn) - more static analysis
* [Halmos](https://github.com/a16z/halmos) - symbolic testing
* [Vertigo](https://github.com/RareSkills/vertigo-rs) - mutation testing

# How to Use...

### Unit Tests
```bash
forge test
```

### Aderyn
```bash
aderyn-check
```

### Slither
```bash
slither .
```

### Solhint
```bash
solhint 'src/**/*.sol'
```

### Echidna
```bash
echidna test/echidna/PredictionMarket.echidna.t.sol --contract PredictionMarketFuzz --config echidna.yaml
```

### Halmos
```bash
FOUNDRY_PROFILE=halmos halmos
```

### Vertigo
```bash
vertigo run --src-dir src
```
