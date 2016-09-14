class Utilities
 require 'typhoeus'
 require 'crack'
 require 'openssl'
 require 'digest/sha1'
 require 'yaml'
 
class << self
	attr_accessor :yaml_usr_load
end

def decrpt_pass()
	self.class.yaml_usr_load = YAML.load_file('./tc.yml')
	cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
	cipher.decrypt
	cipher.key = self.class.yaml_usr_load["key"]

	encrypted = [self.class.yaml_usr_load["encrypted"]].pack "H*"
	decrypted = cipher.update(encrypted)
	decrypted << cipher.final
	return decrypted
end

def http_get_request(url)	
	request = Typhoeus::Request.new(url,
							method: :get,
							userpwd: "svc_teamcityapi:#{decrpt_pass()}",
							headers: { 'ContentType' => "application/json", 'Accept' => 'application/json'}
							)
	return request
end

def http_post_request(url, my_body, my_headers)
	request = Typhoeus::Request.new(url,
					method: :post,
					userpwd: "svc_teamcityapi:#{decrpt_pass()}",
					headers: my_headers,
					body: my_body,
					)
	return request
end

def run_request_parse_json(url)
	response = self.http_get_request(url).run
	return Crack::JSON.parse(response.body)
end

def get_run_time_lapse(start_time, end_time)
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

def create_json_obj(project_name, status, test_name, last_run, test_failed, green_since)
	json = {}
	json["projectName"] = project_name
	json["status"] = status
	json["test_name"] = test_name
	json["last_run"] = last_run
	json["test_failed"] = test_failed
	json["green_since"] = green_since
	return json
end
	
end