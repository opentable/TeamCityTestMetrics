module Utilities
  require "typhoeus"
  require "crack"
  require "openssl"
  require "digest/sha1"
  require "yaml"
 
  def self.decrpt_pass(environment)
    yaml_usr_load = YAML.load_file("./tc.yml")
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = yaml_usr_load[environment]['key']

    encrypted = [yaml_usr_load[environment]['encrypted']].pack "H*"
    decrypted = cipher.update(encrypted)
    decrypted << cipher.final
  end

  def self.http_get_request(url, environment)  
    request = Typhoeus::Request.new(url,
          :method  => :get,
          :userpwd => "svc_teamcityapi:#{decrpt_pass(environment)}",
          :headers => { :ContentType => "application/json", :Accept => "application/json"}
          )
  end

  def self.http_post_request(url, my_body, my_headers, environment)
    request = Typhoeus::Request.new(url,
          :method  => :post,
          :userpwd => "svc_teamcityapi:#{decrpt_pass(environment)}",
          :headers => my_headers,
          :body    => my_body,
          )
  end

  def self.run_request_parse_json(url, environment)
    response = self.http_get_request(url, environment).run
    Crack::JSON.parse(response.body)
  end

  def self.get_lapse_time(start_time, end_time)
    time_lapse_secs = DateTime.parse(end_time).strftime('%s').to_f - DateTime.parse(start_time).strftime('%s').to_f
    mm, ss = time_lapse_secs.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
  
    ##puts "%d days, %d hours, %d minutes and %d seconds" % [dd, hh, mm, ss]
    time_lapse = "#{dd} days ago" if dd > 1
    time_lapse = "#{dd} day ago" if dd == 1
    time_lapse = "#{hh} hours ago" if dd == 0 && hh > 0000
    time_lapse = "#{mm} mins ago" if dd == 0 && hh == 0 && mm > 0
    time_lapse = "#{ss} secs ago" if dd == 0 && hh == 0 && mm == 0
    time_lapse
  end

end