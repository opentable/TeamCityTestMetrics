#!/usr/bin/env ruby

require 'date'
require 'time'
require 'json'
require 'yaml'
require './utilities'
require './teamcity'

utilities = Utilities.new
teamcity = Teamcity.new

YAML_CONFIG_LOAD = YAML.load_file("./project_test.yml")

# ##Fire up a team city test run.
# teamcity.run_tc_test("bt2274")

##Start from the Team City Project
YAML_CONFIG_LOAD.each do | key, value |
	test_info_arr = []
	
    #Sensu info
	sensu_name = key
	environment = value['Environment']
	teams = value['Team']
	
	#TeamCity Info.  Start at the project level to get the build ids
    $Team_City_Host = value['TeamCityHost']
	project_name = value['Project']
	project_test_name = value['Test']

	project_response = teamcity.get_team_city_obj("project", project_name)
	team_city_project_name = teamcity.get_project_name(project_response)

	#Get the list of buildType ids and names (Team City Test Suite names and ids) of the project
	builds_response = teamcity.get_all_builds_obj(project_response,project_test_name)
	test_run_response = teamcity.get_latest_run_obj(builds_response)
	
	#Get the test execution status of the latest run
	test_name = teamcity.get_test_info("name", test_run_response)
	test_status = teamcity.get_test_info("status",test_run_response)
	test_failed = teamcity.get_test_info("test failed", test_run_response)
	finish_date = teamcity.get_test_info("finish date", test_run_response)
	#Calculate the lapse time since the test last executed
	last_run = utilities.get_run_time_lapse(finish_date,DateTime.now.to_s)
	
	green_since = teamcity.get_last_success_run(builds_response)
			
	#Prep the json object for the dashboard
	test_info_arr.push utilities.create_json_obj(sensu_name,environment, teams, test_status, team_city_project_name, test_name, last_run, test_failed, green_since)
	#puts test_info_arr
	puts JSON.generate(test_info_arr)
	#puts "====================="

end