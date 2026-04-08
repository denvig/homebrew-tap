class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.6.3.tgz"
  sha256 "0391855fc034ff031202254eaef0ad092d68625dd95af6cf62d31c6a815afbcf"
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
