require_relative 'base_cli'

module Terjira
  class ProjectCLI < BaseCLI
    default_task :show
    desc "KEY", "show detail of project"
    def show(key = nil)
      if key.nil?
        projects = Client::Project.all
        key = select_project(projects)
      end
      project = Client::Project.find(key)
      redner_project_detail(project)
    end

    desc "list", "list projects"
    map ls: :list
    def list(name = nil)
      projects = Client::Project.all
      render_projects_summary(projects)
    end
  end
end
