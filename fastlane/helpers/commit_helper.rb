require "fastlane"
require_relative "constants.rb"

module Commit_Helper
  include Fastlane
  Sh = Fastlane::Actions

  def self.get_message
    Sh.sh("git add .", log: false)
    output, _ = Open3.capture2("git diff --cached --numstat")

  if output.strip.empty?
    UI.message("⚠️ Staged changes not found to commit")
    return null
  end

  folder_changes = Hash.new { |h, k| h[k] = { added: 0, removed: 0 } }

  output.lines.each do |line|
    added, removed, path = line.strip.split("\t")
    next if added == '-' || removed == '-'

    segments = File.dirname(path).split(File::SEPARATOR)
    folder = segments.empty? ? "." : segments.first(4).join("/")

    folder_changes[folder][:added] += added.to_i
    folder_changes[folder][:removed] += removed.to_i
  end

  sorted = folder_changes.sort_by { |_, v| -(v[:added] + v[:removed]) }

  commit_lines = sorted.map do |folder, data|
    total = data[:added] + data[:removed]
    "#{folder.ljust(40)} | +#{data[:added]} -#{data[:removed]} (#{total} lines)"
  end

  commit_message = "🤖 Changes:\n" + commit_lines.join("\n")

  UI.success("✔️ Commit message by folders:\n#{commit_message}")

  return commit_message
  end
end