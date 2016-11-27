require 'tty-prompt'
require 'tty-table'

module Terjira
  module ProjectPresenter
    def render_projects_summary(projects)
      return puts "Nothing." if projects.blank?
      head = ["KEY", "NAME", "TYPE"].map do |v|
               { value: v, alignment: :center }
             end

      rows = projects.map do |project|
               [{ value: project.key, alignment: :center },
                project.name,
                { value: project.projectTypeKey, alignment: :center} ]
             end

      table = TTY::Table.new head, rows
      pastel = Pastel.new

      result = table.render(:unicode, padding: [0, 1, 0, 1]) do |renderer|
        renderer.filter = proc do |val, ri, ci|
          (ri == 0 || ci == 0) ? pastel.bold(val) : val
        end
      end

      puts result
    end

    def select_project(projects)
      prompt = TTY::Prompt.new
      sep = " - "
      keys = projects.map { |p| [p.key + sep + p.name] }
      prompt.select("Choose project?", keys).split(sep)[0]
    end

    def redner_project_detail(project)
      pastel = Pastel.new
      head = [pastel.blue.on_white.bold(project.key) + " " + project.name]
      rows = []
      rows << [project.description] if project.respond_to?(:description)
      rows << ['']
      lead = project.lead
      rows << [pastel.bold("Lead")]
      rows << ["#{lead.displayName} (#{lead.name})"]
      rows << ['']
      rows << [pastel.bold("Components")]
      rows << [project.components.map(&:name).join(", ")]
      rows << ['']
      rows << [pastel.bold("Users")]
      rows << [project.users.map(&:name).reject { |n| n.include?("addon")}.join("\n")]

      table = TTY::Table.new head, rows
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true)
      puts result
    end
  end
end
