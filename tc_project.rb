class TCProjects
 require 'date'
 require 'time'
 require './utilities'
 
  attr_reader :tc_host, :project_name, :project_test 

  def initialize(tc_host, project_name, project_test)
	@tc_host = tc_host
	@project_name = project_name
	@project_test = project_test
	### e.g. http://teamcity.otenv.com/httpAuth/app/rest/projects/id:ConsumerCucumberTeamInfra
	@tc_project_data = Utilities.run_request_parse_json("#{tc_host}/httpAuth/app/rest/projects/id:#{project_name}")
	@tc_all_builds = self.tc_all_builds
	@tc_last_test_run = self.tc_single_build(@tc_all_builds['build'].first['href'])
  end
  
  def get_tc_project_name
	#Return Team City Project Name
	@tc_project_data['name']
  end
  
  def tc_all_builds
	## Return all the builds for this test suite
	@tc_project_data['buildTypes']['buildType'].each do |buildType|
	   test_suite_name = buildType['name']	  
	   # For each test suite, look for the latest test run status
	   ### e.g. http://teamcity.otenv.com/app/rest/buildTypes/id:bt2274/builds/	  
	   return Utilities.run_request_parse_json("#{@tc_host}#{buildType['href']}/builds")if test_suite_name.downcase.eql? project_test.downcase
     end
  end
  
  def tc_single_build(hrefurl)
	## Return all the info for a single build
	Utilities.run_request_parse_json("#{@tc_host}#{hrefurl}")
  end
  
  def get_tc_project_buildtype_id
	##Return Team City buildtype_id
	@tc_last_test_run['buildType']['id']
  end
  
  def get_test_name
	@tc_last_test_run['buildType']['name']
  end
   
  def get_status
	@tc_last_test_run['status']
  end
   
  def get_test_failed
	if @tc_last_test_run['testOccurrences']['failed'].nil?
		num_failed_tests = 0
	else
		num_failed_tests = @tc_last_test_run['testOccurrences']['failed']
	end
	return "#{num_failed_tests}/#{@tc_last_test_run['testOccurrences']['count']}"
  end
   
  def get_last_run
	Utilities.get_run_time_lapse(@tc_last_test_run['finishDate'], DateTime.now.to_s)
  end
  
  def get_last_success_run
	@tc_all_builds['build'].each do |build|
		if build['status'].downcase == "success"
		  first_success_build = self.tc_single_build(build['href'])
		  #Calculate the lapse time since the test last executed
		  time_lapse = Utilities.get_run_time_lapse(first_success_build['finishDate'],DateTime.now.to_s)
		  return "Last Success: #{time_lapse}"
		end
	end
	last_known_fail_build = tc_single_build(@tc_all_builds['build'].last['href'])
	#Calculate the lapse time since the test last executed
	time_lapse = Utilities.get_run_time_lapse(last_known_fail_build['finishDate'],DateTime.now.to_s)
	return "Last Success: > #{time_lapse}"
  end
end