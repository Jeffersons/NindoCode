require("fastlane")
require_relative "constants.rb"
include Fastlane

module Tests_Helper
  def self.run_unit_tests(lane)
    lane.scan(
      scheme: Constants::SCHEME_NAME,
      workspace: Constants::WORKSPACE_NAME,
      output_directory: "fastlane/#{Constants::LINT_RESULT_PATH}",
      output_types: "html,junit",
      buildlog_path: "fastlane/build_logs",
      code_coverage: true,
      result_bundle: true,
      fail_build: true
    )

    return self.validate_expectations(lane)
  end

  def self.validate_expectations(lane) 
    UI.message("\n\n⚙️ Validating tests coverage expectations...\n")
    
    percent = self.get_coverage(lane)
    expects_data = self.get_expectations()
    expects_coverage = expects_data["tests_coverage_percentage"] 
    
    if percent >= expects_coverage 
      UI.success("\n\n📈 Total Code Coverage: #{percent}% does meet expectations of #{expects_coverage}% 🎉\n")
      return true
    else 
      UI.error("\n\n📈 Total Code Coverage: #{percent}% does not meet expectations of #{expects_coverage}% ❌\n") 
      return false
    end
  end

  def self.get_expectations() 
    json_output = File.read(Constants::EXPECTATIONS_FILE)
    expects_data = JSON.parse(json_output)
    return expects_data
  end

  def self.update_coverage_expectation(new_expectation)
    expects_data = self.get_expectations()
    expects_data["tests_coverage_percentage"] = new_expectation
    File.write(Constants::EXPECTATIONS_FILE, JSON.pretty_generate(expects_data))
  end

  def self.get_coverage(lane)
    result_path = File.join(Dir.pwd, "test_output/#{Constants::SCHEME_NAME}.xcresult")
    
    unless File.exist?(result_path)
      UI.error("\n\n❌ Coverage report not found at: #{result_path}\n")
      return
    end
    
    json_output = lane.sh("xcrun xccov view --report --json '#{result_path}'", log: false)
    coverage_data = JSON.parse(json_output)
    total_coverage = coverage_data["lineCoverage"]
    return (total_coverage.to_f * 100).round(2)
  end
end