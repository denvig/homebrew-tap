class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.6.4.tgz"
  sha256 "b244ef094914b70a05d5c0265bf703b410246c5900db390a88edf9b38c34a8d4"
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
