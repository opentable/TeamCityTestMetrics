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
    last_run = Utilities.get_lapse_time(proj.get_last_run, DateTime.now.to_s).gsub(' ','%20')
    last_green = Utilities.get_lapse_time(proj.get_last_success_run, DateTime.now.to_s).gsub(' ','%20')
    sensu_obj = {
      :name        => "CW_Auto_Metrics_#{k}",
      :environment => env,
      :team        => v['Team'],
      :status      => (proj.get_status == "FAILURE") ? 2 : 0,
      :output      => "Status:%20#{proj.get_status}%0A" \
                      "ProjectName:%20#{proj.get_tc_project_name}%0A" \
                      "TestName:%20#{proj.get_test_name}%0A" \
                      "TestFailed:%20#{proj.get_test_failed}%0A" \
                      "TotalTests:%20#{proj.get_total_tests}%0A" \
                      "LastRun:%20#{last_run}%0A" \
                      "LastRunTimestamp:%20#{proj.get_last_run}%0A" \
                      "GreenSince:%20#{last_green}%0A" \
                      "GreenSinceTimestamp:%20#{proj.get_last_success_run}%0A" \
                      "TeamCityLink:%20'#{proj.get_tc_link}'"
    }
    puts JSON.generate(sensu_obj)
  }
