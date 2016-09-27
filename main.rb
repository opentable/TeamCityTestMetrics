#!/usr/bin/env ruby

require 'json'
require 'yaml'
require './utilities'
require './tc_project'

YAML_CONFIG_LOAD = YAML.load_file("./project_test.yml")

##Start from the Team City Project
YAML_CONFIG_LOAD.each do | key, value |
	
    #Sensu info
	sensu_name = key
	environment = value['Environment']
	teams = value['Team']
	
	#TeamCity project object
	project = TCProjects.new( value['TeamCityHost'], value['Project'], value['Test'] )
    team_city_project_name =  project.get_tc_project_name
	
	#Get the test execution status of the latest run
	test_name = project.get_test_name
	test_status = project.get_status
	test_failed = project.get_test_failed
	last_run = project.get_last_run	
	green_since = project.get_last_success_run
			
	#Prep the json object for the dashboard
	puts JSON.generate(Utilities.create_json_obj(sensu_name,environment, teams, test_status, team_city_project_name, test_name, last_run, test_failed, green_since))

end