require "fastlane"
require_relative "constants.rb"
include Fastlane

module PR_Template_Helper
  def self.get_pr_template(lane)
    input = "n"

    if File.exist?(Constants::PR_CACHE_PATH) 
    cache_file = File.read(Constants::PR_CACHE_PATH)
    cache_data = JSON.parse(cache_file)
    cache_template = self.render_pr_template()

    UI.message("Title: #{cache_data["title"]}")
    UI.message(cache_template)
    input = lane.ask("Do you want to use the saved template? y/n\n")
    else  
    UI.message("ℹ️  Template cache does not exists, creating new template...")
    end

    if input.strip.downcase != "s" && input.strip.downcase != "y"
      self.new_pr_template(lane)
    end

    return self.render_pr_template()
  end

  def self.new_pr_template(lane) 
  title = lane.ask("\nEnter title:")
  description = lane.ask("\nEnter description:")
  checklist = get_template_checklist(lane)
  change_types = get_template_change_types(lane)
  additionals = lane.ask("\nEnter addition context if applicable:")
  reviewer_notes = lane.ask("\nEnter reviewer notes if applicable:")  

  cache_data = { 
    "title" => title,
    "description" => description,
    "checklist" => checklist,
    "change_types" => change_types,
    "additionals" => additionals,
    "reviewer_notes" => reviewer_notes
  }
  FileUtils.mkdir_p(File.dirname(Constants::PR_CACHE_PATH))
  File.write(Constants::PR_CACHE_PATH, JSON.pretty_generate(cache_data))
  end

  def self.render_pr_template()
  template = File.read(Constants::PR_TEMPLATE_PATH)

  if File.exist?(Constants::PR_CACHE_PATH)
    cache_file = File.read(Constants::PR_CACHE_PATH)
    cache_data = JSON.parse(cache_file)
  
    return template
      .gsub("{{description}}", cache_data["description"])
      .gsub("{{checklist}}", cache_data["checklist"])
      .gsub("{{change_types}}", cache_data["change_types"])
      .gsub("{{additionals}}", cache_data["additionals"])
      .gsub("{{reviewer_notes}}", cache_data["reviewer_notes"])
  end
    return nil
  end

  def self.get_template_checklist(lane) 
    list = { 
      1 => "Unit tests completed successfully"
    }
    selecteds = []

    unitTests = lane.ask("\nHave unit tests been done? y/n")
    if unitTests.strip.downcase == "s" || unitTests.strip.downcase == "y"
      selecteds.push(1)
    end

    return list.map do |index, name|
    checked = selecteds.include?(index) ? "x" : " "
    "- [#{checked}] #{name}"
    end.join("\n")
  end

  def self.get_template_change_types(lane) 
    types = {
      "1" => "🚀 New feature",
      "2" => "🐛 Bugfix",
      "3" => "🧹 Refactoring",
      "4" => "🧪 Tests",
      "5" => "📝 Documentation",
      "6" => "🧱 Configuration / Build / CI"
    }
    UI.message("/n🧩 Select the change types:\n")
    types.each do |k, v|
        UI.message("#{k} - #{v}")
    end

    input = lane.ask("Enter the numbers separated by a comma (Example: 1,4):")
    selecteds = input.split(",")
    
    return types.map do |index, type|
      checked = selecteds.include?(index) ? "x" : " "
      "- [#{checked}] #{type}"
    end.join("\n")
  end
end