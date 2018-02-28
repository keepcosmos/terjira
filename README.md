[![Gem Version](https://badge.fury.io/rb/terjira.svg)](https://badge.fury.io/rb/terjira)
[![Build Status](https://travis-ci.org/keepcosmos/terjira.svg?branch=master)](https://travis-ci.org/keepcosmos/terjira)
[![Test Coverage](https://codeclimate.com/github/keepcosmos/terjira/badges/coverage.svg)](https://codeclimate.com/github/keepcosmos/terjira/coverage)
[![Code Climate](https://codeclimate.com/github/keepcosmos/terjira/badges/gpa.svg)](https://codeclimate.com/github/keepcosmos/terjira)

# Terjira

Terjira is an interactive and easy to use command line interface (or Application) for Jira. You do not need to remember the resource key or id. Terjira suggests it with an interactive prompt.

Your Jira must support Rest API 2.0 and Agile Rest API 1.0

## Demo
[Watch full demo](https://www.youtube.com/watch?v=T0hbhaXtH-Y)

[![Sample](./dev/demo.gif)](https://www.youtube.com/watch?v=T0hbhaXtH-Y)

## Installation

Install it yourself as:

    $ gem install terjira

If you have permission problem,

    $ sudo gem install terjira

    # or

    $ gem install terjira --user-install
    # You need to export your gem path


## Usage
```
Authentication:
  jira login                         # Login your Jira
                                     #   [--ssl-config]  with ssl configuration
                                     #   [--proxy-config] with proxy configuration
  jira logout                        # Logout your Jira

Project:
  jira project help [COMMAND]        # Describe one specific subcommand
  jira project ( ls | list )         # List of all projects
  jira project [PROJECT_KEY]         # Show detail of the project

Board:
  jira board help [COMMAND]          # Describe one specific subcommand
  jira board ( ls | list)            # List of all boards
  jira board backlog                 # Backlog from the board


Sprint:
  jira sprint help [COMMAND]         # Describe one specific subcommand
  jira sprint ( ls | list )          # List of all sprint from the board
  jira sprint [SPRINT_ID]            # Show the sprint
  jira sprint active                 # Show active sprints and issues
                                     #   To show issues on the sprint(include no assignee)
                                     #   pass `--assignee ALL` or `-a ALL`.

Issue:
  jira issue help [COMMAND]          # Describe one specific subcommand
  jira issue ( ls | list )           # List of issues
                                     #   default assignee option is current loggined user
                                     #   To show issues of all users(include no assignee)
                                     #   pass `--assignee ALL` or `-a ALL`.
  jira issue jql "[QUERY]"           # Search issues with JQL
                                     # ex)
                                     #   jira issue jql "project = 'TEST' AND summary ~ 'authentication'"
  jira issue search "[SUMMARY]"      # Search for an issues by summary
  jira issue [ISSUE_KEY]             # Show detail of the issue
  jira issue assign [ISSUE_KEY] ([ASSIGNEE])  # Assign the issue to user
  jira issue attach_file [ISSUE_KEY] ([FILE_PATH])  #Attach a file to issue
  jira issue comment [ISSUE_KEY]     # Write comment on the issue
                                     #   pass `-E` or `--editor` to open system default editor for composing comment
  jira issue edit_comment [ISSUE_KEY] ([COMMENT_ID])     # Edit user's comment on the issue.
                                     #   If COMMENT_ID is not given, it will choose user's last comment.
  jira issue delete [ISSUE_KEY]      # Delete the issue
  jira issue edit [ISSUE_KEY]        # Edit the issue
                                     #   pass `-E` or `--editor` to open system default editor for composing issue description
  jira issue new                     # Create an issue
                                     #   pass `-E` or `--editor` to open system default editor for composing issue description
  jira issue open [ISSUE_KEY]        # Open browser
  jira issue url [ISSUE_KEY]         # return url of the issue
  jira issue take [ISSUE_KEY]        # Assign the issue to self
  jira issue trans [ISSUE_KEY] ([STATUS])     # Do transition

```


## Feature Todo
**Contributions are welcome!**
- [x] Add JQL command for find issues
- [x] Search issues by keyword
- [ ] Manage worklog and estimate of issues
- [ ] Manage component and version of issues
- [ ] Track history of transitions
- [ ] More friendly help

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/keepcosmos/terjira. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
