class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.5.tgz"
  sha256 "ea545df1f3e58785263fef20358fe0ffa6de511ef69b7d9e7bb0d5c1ee347c0a"
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
    url "https://registry.npmjs.org/@denvig/cli/-/cli-0.7.5.tgz", using: :nounzip
    sha256 "4ff08952485c5c0818691259e8e875021f7fda36dd5fff30b14c7f424e223be0"
  end

  resource "denvig-sdk" do
    url "https://registry.npmjs.org/@denvig/sdk/-/sdk-0.7.5.tgz", using: :nounzip
    sha256 "2a24e086c33b11d1c00c3083c688c9c08f3894e2119634384408f9a566c3ec36"
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
