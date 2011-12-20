#!/usr/bin/ruby


require 'rubygems'
require 'crack'
require 'active_support' # because of !map:HashWithIndifferentAccess in the YAML for server array instances, this must monkey-patch the YAML parse methods
require 'time'
require 'pp'
gem "amazon-ec2", :require => "AWS"
require 'AWS'
aws = AWS::EC2::Base.new(:access_key_id => 'YOUR ACCESS KEY HERE', :secret_access_key => 'YOUR SECRET ACCESS KEY HERE')


output=`rs_api_examples/bin/rs-get-servers.sh`

blob=Crack::XML.parse output

blob["servers"].each { |x| 
  url="#{x["href"]}/settings"
  
  info=`curl -s -H "X-API-VERSION: 1.0" -b /PATH/TO/YOUR/DOT-RIGHTSCALE/DIRECTORY/.rightscale/rs_api_cookie.txt "#{url}"`
  infoblob=Crack::XML.parse info
  awsid=infoblob["settings"]["aws_id"]
  print "Server: #{x["nickname"]} has AWS ID: '#{awsid}'\n"
  if awsid
    aws.create_tags(:resource_id => awsid,
                    :tag         => [{'Name' => x["nickname"]}])
  else
    print "No AWSID '#{awsid}', skipping"
  end
}

#/api/acct/1/server_arrays/000/instances

arraytext=`curl -s -H "X-API-VERSION: 1.0" -b /PATH/TO/YOUR/DOT-RIGHTSCALE/DIRECTORY/.rightscale/rs_api_cookie.txt "https://my.rightscale.com/api/acct/YOURACCOUNTNUMBER/server_arrays"`

print arraytext

arrays=Crack::XML.parse arraytext
arrays["server_arrays"].each { |arr| 
  url="#{arr["href"]}/instances"
  instancetext=`curl -s -H "X-API-VERSION: 1.0" -b /PATH/TO/YOUR/DOT-RIGHTSCALE/DIRECTORY/.rightscale/rs_api_cookie.txt "#{url}"`
  inst=Crack::XML.parse instancetext
  inst["instances"].each { |i|
    print "#{i["nickname"]} = #{i["resource_uid"]}\n"
    aws.create_tags(:resource_id => i["resource_uid"],:tag => [{'Name' => i["nickname"]}])
  } 
}
