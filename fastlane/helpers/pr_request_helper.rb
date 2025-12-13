require "fastlane"
require_relative "constants.rb"
include Fastlane

module PR_Request_Helper
  def self.new_pull_request(title, body, lane)
    coverage = Tests_Helper.get_coverage(lane)
    violations = Lint_Helper.get_lint_data()[0].count
    expects = Tests_Helper.get_expectations()

    formattedBody = body.gsub("{{coverage}}", <<~BODY
      📈 Total Code Coverage: was #{expects["tests_coverage_percentage"]}% and went to #{coverage}% 🎉
      ⚠️ Total Violations: was #{expects["maximum_warnings"]} and went to #{violations} 🎉
    BODY
    )

    Tests_Helper.update_coverage_expectation(coverage)
    Lint_Helper.update_lint_expectation(violations)

    Readme_Helper.update_readme_with_expectations(
      coverage_before: expects["tests_coverage_percentage"],
      coverage_after: coverage,
      violations_before: expects["maximum_warnings"],
      violations_after: violations
    )

    lane.sh("git add .")
    lane.sh("git add #{Readme_Helper.readme_path}")
    if Git_Helper.have_diffs() 
      lane.sh("git commit -m '📊 Update coverage and lint expectations via Fastlane'")
      lane.sh("git push")
    end

    Git_Helper.open_pull_request_url(title, formattedBody)
  end
end