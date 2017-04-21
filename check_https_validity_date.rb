#!/usr/bin/ruby --
#-*- mode: ruby-mode; coding: utf-8 -*-
# file: check_https_validity_date.rb
#    Created:       <2016/04/28 16:03:49>
#    Last Modified: <2017/04/21 15:40:31>

require 'time'

# [HOSTNAME, DAYS]
hosts = [
  ["example.com", 14],
  ["example.jp", 14]
]

now = Time.now

hosts.each do |host|
  not_after=`openssl s_client -connect #{host[0]}:443 -showcerts 2> /dev/null 0>&2 \
| openssl x509 -noout -dates \
| grep notAfter | sed -e 's/^notAfter\=//'`
  t = Time.parse(not_after.chomp())
  if ! t.gmt?
    t += 32400 # + 9 hours
  end
  if t < now + host[1] * 86400 # day to seconds
    $stderr.puts host[0].to_s + "'s SSL key will be expired at " + t.to_s + "."
  end
end
