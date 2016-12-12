# encoding: utf-8

require 'tty-prompt'
require 'tty-table'

module Terjira
  module ProjectPresenter
    def render_projects_summary(projects)
      return render('Nothing.') if projects.blank?
      head = %w(KEY NAME TYPE).map do |v|
        { value: v, alignment: :center }
      end

      rows = projects.map do |project|
        [project.key, project.name, project.projectTypeKey]
      end

      table = TTY::Table.new head, rows
      pastel = Pastel.new

      result = table.render(:unicode, padding: [0, 1, 0, 1]) do |renderer|
        renderer.filter = proc do |val, ri, ci|
          if ri.zero? || ci.zero?
            pastel.bold(val)
          else
            val
          end
        end
      end

      render(result)
    end

    def redner_project_detail(project)
      head = nil
      rows = []
      rows << (pastel.blue.bold(project.key) + ' ' + project.name)
      if project.respond_to?(:description)
        rows << ''
        rows << pastel.bold('Description')
        rows << (project.description.strip.empty? ? 'None' : project.description)
      end
      rows << ''

      rows << pastel.bold('Lead')
      rows << username_with_email(project.lead)
      rows << ''
      rows << render_components_and_versions(project)

      table = TTY::Table.new head, rows.map { |row| [row] }
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true)
      render(result)
    end

    def render_components_and_versions(project)
      componets = project.components.map(&:name)
      componets = componets.size.zero? ? 'Empty' : componets.join("\n")
      versions = project.versions.reject(&:released).map(&:name)
      versions = versions.size.zero? ? 'Empty' : versions.join("\n")

      header = [pastel.bold('Components'),
                pastel.bold('Unreleased versions')]
      row = [[componets, versions]]

      table = TTY::Table.new(header, row)
      table.render(padding: [0, 1, 0, 0], multiline: true)
    end
  end
end
