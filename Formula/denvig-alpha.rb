class DenvigAlpha < Formula
  desc "CLI tool to consistently manage cross-discipline projects (alpha)"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.0-alpha.6.tgz"
  sha256 "cc5588c29f5da5196dd7422eb134754c283eddb983453cac04ef5e06f08e22a9"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/denvig/alpha"
    strategy :json do |json|
      json["version"]
    end
  end

  keg_only "this formula tracks the pre-release `alpha` npm dist-tag; conflicts with `denvig`"

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
    url "https://registry.npmjs.org/@denvig/cli/-/cli-0.7.0-alpha.6.tgz", using: :nounzip
    sha256 "75be68279c3c0239dd5d48762cb0ef6b7852e6cf55cd7dc4f142340674967c53"
  end

  resource "denvig-sdk" do
    url "https://registry.npmjs.org/@denvig/sdk/-/sdk-0.7.0-alpha.6.tgz", using: :nounzip
    sha256 "357e013d81f18484b711d5d685aceecec6c5eb8e71ad5d357ef0c40e4910e8a6"
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
