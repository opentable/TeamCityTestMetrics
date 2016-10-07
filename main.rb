#!/usr/bin/env ruby

  require 'json'
  require 'yaml'
  require './utilities'
  require './tc_project'

  YAML_CONFIG_LOAD = YAML.load_file("./project_test.yml")

  YAML_CONFIG_LOAD.each do | key, value |

    #TeamCity project object for a test suite
    project = TCProjects.new(value['TeamCityHost'], value['Project'], value['Test'], value['Environment'])
    last_run = 
    
    sensu_obj = {
      'name'        => key,
      'environment' => value['Environment'],
      'team'        => value['Team'],
      'status'      => (project.get_status == "FAILURE") ? 1 : 0,
      'output'      => {
                    'Status'                => project.get_status,
                    'Project Name'          => project.get_tc_project_name,
                    'Test Name'             => project.get_test_name,
                    'Test Failed'           => project.get_test_failed,
                    'Total Tests'           => project.get_total_tests,
                    'Last Run'              => Utilities.get_run_time_lapse(project.get_last_run, DateTime.now.to_s),
                    'Last Run Timestamp'    => project.get_last_run,
                    'Green Since'           => Utilities.get_run_time_lapse(project.get_last_success_run, DateTime.now.to_s),
                    'Green Since Timestamp' => project.get_last_success_run,
                       }
    }
    puts JSON.generate(sensu_obj)
  end