class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.6.7.tgz"
  sha256 "c9840b6bb54c02343a7e98fa1b831c185605c30f2ebee81aaf0d0d3eed5c33a0"
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
