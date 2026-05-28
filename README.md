# Denvig Homebrew Tap

A CLI tool to consistently manage cross-discipline projects

## Installation

Stable release:

```bash
brew install denvig/tap/denvig
```

Alpha release (tracks the `alpha` dist-tag on npm):

```bash
brew install denvig/tap/denvig@alpha
```

The two formulae can be installed side-by-side. `denvig@alpha` is keg-only,
so only `denvig` is linked into your `PATH` by default.

### Switching between versions

Link the alpha build (unlinks the stable one):

```bash
brew unlink denvig && brew link --overwrite denvig@alpha
```

Switch back to stable:

```bash
brew unlink denvig@alpha && brew link denvig
```

## Usage

```bash
denvig --help
```
