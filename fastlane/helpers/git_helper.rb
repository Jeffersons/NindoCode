require "uri"
require "fastlane"

require "uri"
require "fastlane"

module Git_Helper
  include Fastlane
  Sh = Fastlane::Actions

  def self.current_repo_from_git_config
    config_path = File.expand_path("../../.git/config", __dir__)

    unless File.exist?(config_path)
      UI.error("❌ .git/config not found at: #{config_path}")
      return ""
    end

    content = File.read(config_path)
    remote_url = content[/\[remote "origin"\][^\[]*url\s*=\s*(.*)/, 1]&.strip

    if remote_url.nil?
      UI.error("❌ Could not extract remote URL from .git/config")
      return ""
    end

    repo_path = remote_url
      .sub("git@github.com:", "")
      .sub("https://github.com/", "")
      .sub(".git", "")

    UI.message("📦 Remote repo: #{repo_path}")
    repo_path
  end

  def self.current_branch
    Sh.sh("git rev-parse --abbrev-ref HEAD", log: false).strip
  end

  def self.open_pull_request_url(title, body, base_branch: "development")
    repo = current_repo_from_git_config
    head = current_branch

    if repo.empty? || head.empty?
      UI.message("✅ Code pushed. Create your PR manually.")
      return
    end

    encoded_title = URI.encode_www_form_component(title)
    encoded_body = URI.encode_www_form_component(body)
    pr_url = "https://github.com/#{repo}/compare/#{base_branch}...#{head}?expand=1&title=#{encoded_title}&body=#{encoded_body}"

    UI.success("🔗 Pull Request URL: #{pr_url}")
    Sh.sh("open '#{pr_url}'")
  end

  def self.isDevelopBranch
    self.current_branch() == "development"
  end

  def self.check_for_diffs()
    can_commit = !self.have_diffs()

    if can_commit
      return true
    else 
      UI.error("\n\nChanges need to be commited before creating pull request ❌\n")
      return false
    end
  end

  def self.have_diffs()
    diffs = Sh.sh("git status --porcelain", log: false)
    return !diffs.empty?
  end

  def self.check_for_blocked_files_changes()
    current_branch = Sh.sh("git rev-parse --abbrev-ref HEAD", log: false).strip
    diffs = Sh.sh("git diff --name-only development #{current_branch}")
  
    if diffs.split("\n").include?("fastlane/#{Constants::EXPECTATIONS_FILE}")
      UI.Error("⚠️  expectation.json shouldn't be changed, please revert changes")
      return false
    else
       UI.message("✅  no changes founded for expectation.json")
       return true
    end
  end
end