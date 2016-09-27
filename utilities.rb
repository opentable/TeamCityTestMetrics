module Utilities
 require 'typhoeus'
 require 'crack'
 require 'openssl'
 require 'digest/sha1'
 require 'yaml'
 
 def Utilities.decrpt_pass()
	yaml_usr_load = YAML.load_file('./tc.yml')
	cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
	cipher.decrypt
	cipher.key = yaml_usr_load["key"]

	encrypted = [yaml_usr_load["encrypted"]].pack "H*"
	decrypted = cipher.update(encrypted)
	decrypted << cipher.final
	return decrypted
 end

 def Utilities.http_get_request(url)	
	request = Typhoeus::Request.new(url,
							method: :get,
							userpwd: "svc_teamcityapi:#{decrpt_pass()}",
							headers: { 'ContentType' => "application/json", 'Accept' => 'application/json'}
							)
	return request
 end

 def Utilities.http_post_request(url, my_body, my_headers)
	request = Typhoeus::Request.new(url,
					method: :post,
					userpwd: "svc_teamcityapi:#{decrpt_pass()}",
					headers: my_headers,
					body: my_body,
					)
	return request
 end

 def Utilities.run_request_parse_json(url)
	response = self.http_get_request(url).run
	return Crack::JSON.parse(response.body)
 end

 def Utilities.get_run_time_lapse(start_time, end_time)
	time_lapse_secs = DateTime.parse(end_time).strftime('%s').to_f - DateTime.parse(start_time).strftime('%s').to_f
	mm, ss = time_lapse_secs.divmod(60)            
	hh, mm = mm.divmod(60)           
	dd, hh = hh.divmod(24)           
	
	##puts "%d days, %d hours, %d minutes and %d seconds" % [dd, hh, mm, ss]
	return "#{dd} days ago" if dd > 1
	return "#{dd} day ago" if dd == 1
	return "#{hh} hours ago" if dd == 0 && hh > 0000
	return "#{mm} mins ago" if dd == 0 && hh == 0 && mm > 0
	return "#{ss} secs ago" if dd == 0 && hh == 0 && mm == 0
 end

 def Utilities.create_json_obj(sensu_name,environment, teams, test_status, project_name, test_name, last_run, test_failed, green_since)
	json = {}
	status = 0
	status = 1 if test_status == 'FAILURE'
	output = "Status: #{test_status}, ProjectName: #{project_name}, Test Name: #{test_name}, Test Failed: #{test_failed}, Last Run: #{last_run}, Green_Since: #{green_since}"
	json["name"] = sensu_name
	json["environment"] = environment
	json["team"] = teams
	json["status"] = status 
	json["output"] = output
	return json
 end
	
end