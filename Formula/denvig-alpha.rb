class DenvigAlpha < Formula
  desc "A CLI tool to consistently manage cross-discipline projects (alpha)"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.0-alpha.2.tgz"
  sha256 "e39ca761afe5b5da8a9f82a4e353c249e785fb6e06e0a1aeaec205aa3b6ff8dc"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/denvig/alpha"
    strategy :json do |json|
      json["version"]
    end
  end

  keg_only "this formula tracks the pre-release `alpha` npm dist-tag; conflicts with `denvig`"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    generate_completions_from_executable(bin/"denvig", "zsh", "completions", shells: [:zsh], shell_parameter_format: :none)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/denvig --version")
  end
end
