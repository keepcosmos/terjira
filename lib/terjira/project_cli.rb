require_relative 'base_cli'

module Terjira
  class ProjectCLI < BaseCLI
    default_task :show

    desc "[KEY]", "show detail of project"
    map ls: :lsit
    def show(key = nil)
      key = select_project if key.nil?
      project = Client::Project.find(key)
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
