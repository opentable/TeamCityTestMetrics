class TCProjects
  require 'date'
  require 'time'
  require './utilities'
 
  attr_reader :tc_host, :project_name, :project_test, :environment

  def initialize(tc_host, project_name, project_test, environment)
    @tc_host = tc_host
    @project_name = project_name
    @project_test = project_test
    @environment = environment
    ## e.g. http://teamcity.otenv.com/httpAuth/app/rest/projects/id:ConsumerCucumberTeamInfra
    @tc_project_data = Utilities.run_request_parse_json("#{tc_host}/httpAuth/app/rest/projects/id:#{project_name}", @environment)
    @tc_all_builds = self.get_tc_all_builds
    @tc_last_test_run = self.get_tc_single_build(@tc_all_builds['build'].first['href'])
  end
  
  def get_tc_project_name
    ##Return Team City Project Name
    @tc_project_data['name']
  end
  
  def get_tc_all_builds
    ## Return all the builds for this test suite
    ## e.g. http://teamcity.otenv.com/app/rest/buildTypes/id:bt2274/builds/
    buildHref = @tc_project_data['buildTypes']['buildType'].find {|buildType| buildType['name'] == project_test}['href']
    Utilities.run_request_parse_json("#{@tc_host}#{buildHref}/builds", @environment) 
  end
  
  def get_tc_single_build(hrefurl)
    ## Return all the info for a single build
    Utilities.run_request_parse_json("#{@tc_host}#{hrefurl}", @environment)
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
    (@tc_last_test_run['testOccurrences']['failed'].nil?) ? num_failed_tests = 0 : num_failed_tests = @tc_last_test_run['testOccurrences']['failed']
    "#{num_failed_tests}/#{@tc_last_test_run['testOccurrences']['count']}"
  end
   
  def get_last_run
    Utilities.get_run_time_lapse(@tc_last_test_run['finishDate'], DateTime.now.to_s)
  end
  
  def get_last_success_run
    if !(@tc_all_builds['build'].find {|build| build['status'] == "SUCCESS"}.nil?)
      successHref = @tc_all_builds['build'].find {|build| build['status'] == "SUCCESS"}['href']
      @tc_first_success_build = self.get_tc_single_build(successHref)
      time_lapse = Utilities.get_run_time_lapse(@tc_first_success_build['finishDate'], DateTime.now.to_s)
      "Last Success: #{time_lapse}"
    else
      @tc_last_known_fail_build = self.get_tc_single_build(@tc_all_builds['build'].last['href'])
      ##Calculate the lapse time since the test last executed
      time_lapse = Utilities.get_run_time_lapse(@tc_last_known_fail_build['finishDate'], DateTime.now.to_s)
      "Last Success: > #{time_lapse}"
    end
  end
end