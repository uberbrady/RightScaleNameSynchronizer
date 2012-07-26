#!/usr/bin/env ruby

require 'RightScaleAPIHelper'
require 'optparse'
require 'json'
require 'base64'
require 'AWS'
require 'yaml'

def process_yaml()

  opts = OptionParser.new

  opts.on("-y", "--yaml PATH_TO_YAML_FILE", String) do |val|
    if File.exist?(val)
      app_config = YAML.load_file(val)
      @username = app_config['username']
      @password = app_config['password']
      @account_id = app_config['account_id']
      if app_config['base64']
        @base64 = true
      end
      AWS.config(app_config)
    else
      puts "YAML configuration file does not exist. file: %s\nExiting" % val
      exit(1)
    end
  end
 
  # Assign Variables
  opts.on("-u", "--username RightScaleUsername", String) {|val| @username = val }
  opts.on("-p", "--password RightScalePassword", String) {|val| @password = val }
  opts.on("-a", "--account_id RSAccountID", Integer) {|val| @account_id = val}
  opts.on("--aws-key Amazon_Key", String) {|val| @aws_key = val }
  opts.on("--aww-secret Amazon_Secret", String) {|val| @aws_secret = val}
  opts.on("--base64[=OPT]", TrueClass) {|val| @base64 = true}
  opts.on("-h", "--help", "Show Help|Usage Information") do
    puts opts.to_s
    exit(0)
  end

  opts.parse(ARGV)

end


def rs_conn()
  if @base64
    api_conn = RightScaleAPIHelper::Helper.new(@account_id, Base64.decode64(@username), Base64.decode64(@password), format="js", version="1.0")
  else
    api_conn = RightScaleAPIHelper::Helper.new(@account_id, @username, @password, format="js", version="1.0")
  end
  return api_conn
end

def which_ec2_conn(rs_cloud_id)
      case rs_cloud_id 
      when 1
        ec2conn = @ec2
      when 3
        ec2conn = @ec2.regions['us-west-1']
      else
        ec2conn = @ec2
      end
      return ec2conn
end

def update_servers(server_list)
  puts "Updating Servers"
  server_list.each do |server|
    # Don't do anything if the server is not in operational state'
    if server['state'] == "operational"
      resp = @api_conn.get(server['href'].sub(/^.*servers/, "/servers") + "/current/settings")
      server_settings = JSON.parse(resp.body)
      aws_id = server_settings['aws_id']

      # Write the tag on the server 
      which_ec2_conn(server_settings['cloud_id']).instances[aws_id].tag("Name", :value => server['nickname'])
    end
  end
end

begin

  process_yaml
  @api_conn = rs_conn


  @ec2 = AWS::EC2.new  # Connects to us-east-1

  resp = @api_conn.get("/servers")
  server_list = JSON.parse(resp.body)

  update_servers(server_list)


  # This is broken until I add a bunch of try and catches as the rightscale api
  # is a bit broken when it comes to server arrays.

  #  resp = @api_conn.get("/server_arrays")
#  server_arrays = JSON.parse(resp.body)
#  puts "Updating Array Servers"
#  puts server_arrays
#
#  server_arrays.each do |server_array|
#    puts server_array
#    if server_array['active_instances_count'].to_i > 0
#      resp = @api_conn.get(server_array['href'].sub(/^.*server_arrays/, "/server_arrays") + "/instances")
#      array_instances = JSON.parse(resp.body)
#      array_instances.each do |instance|
#        #puts instance
#        puts "#{instance['nickname']} = #{instance['resource_uid']}"
#        ec2conn = which_ec2_conn(instance['cloud_id'])
#        puts "cloud_id = #{instance['cloud_id']}"
#        unless ec2conn.nil? 
#          ec2conn.instances[instance['resource_uid']].tag("Name", :value => instance['nickname'])
#        end
#        
##        aws.create_tag(instance['resource_uid'], [{'Name' => instance['nickname']}]) 
#      end
#    end
#  end
end


# ToDo
