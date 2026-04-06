class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.6.2.tgz"
  sha256 "0260d4cc391bce9b804892d3cde5fa64e6adc4a9caaa4d4a4da952392389fc5d"
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
