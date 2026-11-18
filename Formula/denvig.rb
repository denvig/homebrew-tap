class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.7.tgz"
  sha256 "42467889417ee6cbe1a8aae2865b8d87c61c24eee15713ef5360393ea0270ce8"
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
    url "https://registry.npmjs.org/@denvig/cli/-/cli-0.7.7.tgz", using: :nounzip
    sha256 "328194f7b7d127d56304b48104babde322fbe37c9ffacc06cb46e91e636947da"
  end

  resource "denvig-sdk" do
    url "https://registry.npmjs.org/@denvig/sdk/-/sdk-0.7.7.tgz", using: :nounzip
    sha256 "f4d278de3adbaa5a730bbeda8cfc4b3740a34d37ec66441efe1d628bb7b4a906"
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
