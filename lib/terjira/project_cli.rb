require_relative 'base_cli'

module Terjira
  class ProjectCLI < BaseCLI
    default_task :show

    desc "[PROJECT_KEY]", "show detail of project"
    map ls: :lsit
    def show(project_key = nil)
      if project_key.nil?
        project = select_project
        project_key = project.key_value
      end

      project = Client::Project.find(project_key)
      redner_project_detail(project)
    end

    desc "list(ls)", "list projects"
    map ls: :list
    def list(name = nil)
      projects = Client::Project.all
      render_projects_summary(projects)
    end
  end
end
