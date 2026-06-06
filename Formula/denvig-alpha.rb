class DenvigAlpha < Formula
  desc "A CLI tool to consistently manage cross-discipline projects (alpha)"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.0-alpha.4.tgz"
  sha256 "807c1c819ac3e3d8077721f1450518a06be5c263d806e89299143c2084b2eebb"
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

    generate_completions_from_executable(bin/"denvig", "shell", "completions", shells: [:zsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/denvig --version")
  end
end
