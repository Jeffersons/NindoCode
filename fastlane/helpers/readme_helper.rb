module Readme_Helper
  def self.readme_path
    File.expand_path("../../../README.md", __FILE__)
  end

  def self.progress_bar(percentage, total_blocks = 10)
    filled_blocks = (percentage / 100.0 * total_blocks).round
    empty_blocks = total_blocks - filled_blocks
    "🟩" * filled_blocks + "⬜️" * empty_blocks
  end

  def self.update_readme_with_expectations(coverage_before:, coverage_after:, violations_before:, violations_after:)
    readme = File.read(readme_path)

    author = `git log -1 --pretty=format:'%an'`.strip

    updated_block = <<~MARKDOWN.strip
      <!-- EXPECTATIONS_START -->
      📊 Expectations  
      📈 Total Code Coverage: was #{coverage_before}% and went to #{coverage_after}% 🎉  
      #{progress_bar(coverage_after)} (#{coverage_after}%)  
      ⚠️ Total Violations: was #{violations_before} and went to #{violations_after} 🎉  
      
      ✍️ Last Updated by: #{author}
      <!-- EXPECTATIONS_END -->
    MARKDOWN

    updated_readme = if readme.match(/<!-- EXPECTATIONS_START -->.*?<!-- EXPECTATIONS_END -->/m)
      readme.gsub(/<!-- EXPECTATIONS_START -->.*?<!-- EXPECTATIONS_END -->/m, updated_block)
    else
      readme + "\n\n" + updated_block
    end

    File.write(readme_path, updated_readme)
    UI.success("✅ README.md updated with test coverage and lint results.")
  end
end