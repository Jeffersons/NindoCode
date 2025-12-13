require "fastlane"
require_relative "tests_helper.rb"
require_relative "constants.rb"
include Fastlane

module Lint_Helper
  def self.run_swift_lint(lane)
    result_path = File.join(Dir.pwd, Constants::LINT_RESULT_PATH)
    FileUtils.mkdir_p(result_path)

    lane.swiftlint(
      mode: :lint,
      output_file: "#{result_path}/swiftlint.json",
      reporter: "json",
      config_file: ".swiftlint.yml",
      raise_if_swiftlint_error: false,
      ignore_exit_status: true,
    )

    return validate_lint_data()
  end

  def self.validate_lint_data()
    unless File.exist?(Constants::LINT_RESULT_PATH)
      UI.error("\n\n❌ SwiftLint report not found at: #{Constants::LINT_RESULT_PATH}\n")
      return
    end
    lint_data = self.get_lint_data()
    violations = lint_data[0]
    errors = lint_data[1]

    UI.message("\n\n⚙️ Processing SwiftLint violations...\n")
      expects_data = Tests_Helper.get_expectations()
      expectations = expects_data["maximum_warnings"]

      if errors.count > 0
        UI.error("\n\n❌ Errors have been encountered, please fix and try again\n")
        return false
      elsif violations.count <= expectations
        UI.success("\n\n📈 Total Violations: #{violations.count} does meet expectations of #{expectations} 🎉\n")
        return true
      else
        UI.error("\n\n📈 Total Violations: #{violations.count} does not meet expectations of #{expectations} ❌\n")
        return false
      end
  end

  def self.get_lint_data() 
    begin
    result_path = File.join(Dir.pwd, Constants::LINT_RESULT_PATH, "swiftlint.json")
    file_content = File.read(result_path).partition("]").first + "]"
    result = JSON.parse(file_content)
    errors = []
    violations = []

    result.each do |element|
      if element["severity"] == "Warning"
        violations.push(element)
      elsif element["severity"] == "Error"
        errors.push(element)
      end
    end
    return [violations, errors]

    rescue JSON::ParserError => e
      UI.error("Error to parse swift lint: #{e.message} ❌")
      return []
    end
  end

  def self.update_lint_expectation(new_expectation) 
    expects_data = Tests_Helper.get_expectations()
    expects_data["maximum_warnings"] = new_expectation
    File.write(Constants::EXPECTATIONS_FILE, JSON.pretty_generate(expects_data))
  end
end