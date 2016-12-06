# encoding: utf-8

require 'tty-prompt'
require 'tty-table'

module Terjira
  module ProjectPresenter
    def render_projects_summary(projects)
      return render("Nothing.") if projects.blank?
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

      render(result)
    end

    def redner_project_detail(project)
      head = nil
      rows = []
      rows << (pastel.blue.bold(project.key) + " " + project.name)
      if project.respond_to?(:description)
        rows << ''
        rows << pastel.bold("Description")
        rows << (project.description.strip.empty? ? "None" : project.description)
      end
      rows << ''
      lead = project.lead
      rows << pastel.bold("Lead")
      rows << "#{lead.displayName} (#{lead.name})"
      rows << ''
      rows << render_components_and_versions(project)

      table = TTY::Table.new head, rows.map { |row| [row] }
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true)
      render(result)
    end

    def render_components_and_versions(project)
      componets = project.components.map(&:name)
      componets = componets.size == 0 ? "Empty" : componets.join("\n")
      versions = project.versions.reject { |v| v.released }.map(&:name)
      versions = versions.size == 0 ? "Empty" : versions.join("\n")

      header = [pastel.bold("Components"), pastel.bold("Unreleased versions")]
      row = [[componets, versions]]

      table = TTY::Table.new(header, row)
      table.render(padding: [0, 1, 0, 0], multiline: true)
    end
  end
end
