class Denvig < Formula
  desc "A CLI tool to consistently manage cross-discipline projects"
  homepage "https://denvig.com"
  url "https://registry.npmjs.org/denvig/-/denvig-0.7.0.tgz"
  sha256 "aca79abe9d29d2bcea5b0d1471d9fc4c0a1e54fa5ec1427a1802a447d25efe7d"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/denvig/latest"
    strategy :json do |json|
      json["version"]
    end
  end

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
