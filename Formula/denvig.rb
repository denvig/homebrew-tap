class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.6.6.tgz"
  sha256 "b03e8a417c1d89f2ae2cbbf07ff6bbfb1cc6ad4ed4ad90a5b3a6e4c72d9510bb"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    generate_completions_from_executable(bin/"denvig", "zsh", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/denvig --version")
  end
end
