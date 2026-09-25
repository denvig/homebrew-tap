class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.3.tgz"
  sha256 "12cf2433a18e13dc74140dcbc26947ccf9fe2ae4898979fd0013802384c4ca9d"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/denvig/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on "node"

  # denvig depends on the first-party @denvig/cli and @denvig/sdk packages, which are
  # published in the same release as denvig itself. Homebrew's npm install injects a
  # --min-release-age cooldown that rejects these freshly published deps with an ETARGET
  # "no matching version ... with a date before" error. npm has no per-package cooldown
  # exemption, so we vendor the two first-party tarballs here and install them from disk;
  # the third-party deps (node-forge, semver, yaml, zod) still resolve from the registry
  # under the normal cooldown. These must be bumped in lockstep with the denvig url above
  # (the update-formula workflow does this automatically).
  resource "denvig-cli" do
    url "https://registry.npmjs.org/@denvig/cli/-/cli-0.7.3.tgz", using: :nounzip
    sha256 "0b0fc2b1572f3d6cc4d3a99b885acc659483775da1529088311f28bbdf08186c"
  end

  resource "denvig-sdk" do
    url "https://registry.npmjs.org/@denvig/sdk/-/sdk-0.7.3.tgz", using: :nounzip
    sha256 "9b25fb93a25df2678653d60efd70fb1f28e309e58eda0a43ad4ac2b469a3c280"
  end

  def install
    # Stage the first-party tarballs without extraction.
    vendor = buildpath/"homebrew-vendor"
    vendor.mkpath
    resource("denvig-cli").stage { cp Dir["*"].first, vendor/"denvig-cli.tgz" }
    resource("denvig-sdk").stage { cp Dir["*"].first, vendor/"denvig-sdk.tgz" }

    # Repoint denvig's own @denvig/* dependencies at the vendored tarballs. A file: dep is
    # installed from disk and skips npm's release-age cooldown, while third-party deps
    # still resolve from the registry under it. (npm refuses an `overrides` entry for a
    # direct dependency, so we rewrite the dependency specs directly.)
    package = buildpath/"package.json"
    pkg_json = JSON.parse(package.read)
    pkg_json["dependencies"]["@denvig/cli"] = "file:#{vendor}/denvig-cli.tgz"
    pkg_json["dependencies"]["@denvig/sdk"] = "file:#{vendor}/denvig-sdk.tgz"
    package.atomic_write(JSON.pretty_generate(pkg_json))

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    generate_completions_from_executable(bin/"denvig", "shell", "completions", shells: [:zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/denvig --version")
  end
end
