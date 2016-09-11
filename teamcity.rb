class Teamcity
 require 'typhoeus'
 require 'crack'
 require 'builder'
 require './utilities'
 
 $Team_City_Host = "teamcity.otenv.com"
 
 def get_team_city_obj(type, urlvalue)
    if type == "project"
		### e.g. http://teamcity.otenv.com/httpAuth/app/rest/projects/id:ConsumerCucumberTeamInfra
		url = "#{$Team_City_Host}/httpAuth/app/rest/projects/id:#{urlvalue}"
		##puts "url=>#{url}"
	elsif type == "all_builds"
		### e.g. http://teamcity.otenv.com/app/rest/buildTypes/id:bt2274/builds/
		url = "#{$Team_City_Host}#{urlvalue}/builds"
	elsif type == "single_build"
		### e.g. http://teamcity.otenv.com/app/rest/builds/id:5138895
		url = "#{$Team_City_Host}#{urlvalue}"
	end
	return Utilities.new.run_request_parse_xml(url)
 end
 
 def run_tc_test(buildTypeid)
 	my_headers = {'Content-Type' => "application/xml"}
	url = "#{$Team_City_Host}/httpAuth/app/rest/buildQueue"
	xml_body = "<build><buildType id='#{buildTypeid}'/></build>"
	request = Utilities.new.http_post_request(url, xml_body, my_headers)
	response = request.run
	puts response.body
 end
 
 def get_project_name(obj)
	return obj['project']['name']
 end
 
 def get_buildType_obj(obj)
	return obj['project']['buildTypes']['buildType']
 end
 
  def get_all_builds_obj(xml_project_response,project_test_name)
	self.get_buildType_obj(xml_project_response).each do |buildType|
		test_suite_name = buildType['name']		
		# For each test suite, look for the latest test run status
		return self.get_team_city_obj("all_builds", buildType['href']) if test_suite_name.downcase.eql? project_test_name.chop.downcase
	end
 end
 
 def get_latest_run_obj(xml_builds_response)		    		
	#Get the latest run url from the list of builds and drill down
	latest_run = xml_builds_response['builds']['build'].first
	return self.get_team_city_obj("single_build", latest_run['href'])
 end
 
 def get_last_success_run(xml_builds_response)
    xml_builds_response['builds']['build'].each do |build|
	  if build['status'].downcase == "success"
		xml_single_build_response = self.get_team_city_obj("single_build", build['href'])
		finish_date = self.get_test_info("finish date", xml_single_build_response)
		#Calculate the lapse time since the test last executed
		time_lapse = Utilities.new.get_run_time_lapse(finish_date,DateTime.now.to_s)
		return "Last Success: #{time_lapse}"
	  end
	end
	last_known_fail = xml_builds_response['builds']['build'].last
	xml_single_build_response = self.get_team_city_obj("single_build", last_known_fail['href'])
	finish_date = self.get_test_info("finish date", xml_single_build_response)
	#Calculate the lapse time since the test last executed
	time_lapse = Utilities.new.get_run_time_lapse(finish_date,DateTime.now.to_s)
	return "Last Success: > #{time_lapse}"
 end
 
 def get_test_info(type, obj)
	if type.downcase == "name"
		return obj['build']['buildType']['name']
	elsif type.downcase == "status"
		return obj['build']['status']
	elsif type.downcase == "test failed"
		return "#{obj['build']['testOccurrences']['failed']}/#{obj['build']['testOccurrences']['count']}"
	elsif type.downcase == "finish date"
		return obj['build']['finishDate']
	end
 end
	
end