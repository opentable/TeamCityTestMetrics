#!/usr/bin/env ruby
  require "json"
  require "yaml"
  require "./utilities"
  require "./tc_project"

  env = ARGV[0].strip
  yml_contents = YAML.load_file("./project_test.yml")
  test_hash = env == "preprod" ? yml_contents['preprod'] : yml_contents['production']

  test_hash.each { | k, v |
    #TeamCity project object for a test suite
    proj = TCProjects.new(v['TeamCityHost'], v['Project'], v['Test'], env)
    last_run = Utilities.get_lapse_time(proj.get_last_run, DateTime.now.to_s)
    last_green = Utilities.get_lapse_time(proj.get_last_success_run, DateTime.now.to_s)
    sensu_obj = {
      :name        => "CW_Auto_Metrics_#{k}",
      :environment => env,
      :team        => v['Team'],
      :status      => (proj.get_status == "FAILURE") ? 2 : 0,
      :output      => "Status: #{proj.get_status}\\n" \
                      "ProjectName: #{proj.get_tc_project_name}\\n" \
                      "TestName: #{proj.get_test_name}\\n" \
                      "TestFailed: #{proj.get_test_failed}\\n" \
                      "TotalTests: #{proj.get_total_tests}\\n" \
                      "LastRun: #{last_run}\\n" \
                      "LastRunTimestamp: #{proj.get_last_run}\\n" \
                      "GreenSince: #{last_green}\\n" \
                      "GreenSinceTimestamp: #{proj.get_last_success_run}\\n" \
                      "TeamCityLink: ['#{proj.get_tc_link}']"
    }
    puts JSON.generate(sensu_obj)
  }
