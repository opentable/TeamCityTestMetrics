#!/usr/bin/env ruby

require 'date'
require 'time'
require 'json'
require './utilities'
require './teamcity'
 
utilities = Utilities.new
teamcity = Teamcity.new

# ##Fire up a team city test run.
# teamcity.run_tc_test("bt2274")

##Start from the Team City Project
File.read("project_test.txt").each_line{ |file_line|
	test_info_arr = []
	
	#Start at the project level to get the build ids
	project_name, project_test_name = file_line.split(/:/)
	project_response = teamcity.get_team_city_obj("project", project_name)
	team_city_project_name = teamcity.get_project_name(project_response)

	#Get the list of buildType ids and names (Team City Test Suite names and ids) of the project
	builds_response = teamcity.get_all_builds_obj(project_response,project_test_name)
	test_run_response = teamcity.get_latest_run_obj(builds_response)
	
	#Get the test execution status of the latest run
	test_name = teamcity.get_test_info("name", test_run_response)
	status = teamcity.get_test_info("status",test_run_response)
	test_failed = teamcity.get_test_info("test failed", test_run_response)
	finish_date = teamcity.get_test_info("finish date", test_run_response)
	#Calculate the lapse time since the test last executed
	last_run = utilities.get_run_time_lapse(finish_date,DateTime.now.to_s)
	
	green_since = teamcity.get_last_success_run(builds_response)
			
	#Prep the json object for the dashboard
	test_info_arr.push utilities.create_json_obj(team_city_project_name, status, test_name, last_run, test_failed, green_since)
	puts JSON.generate(test_info_arr)
	puts "====================="
}