#
# pakiti_send.rb
#

require 'net/http'
require 'net/https'

module Puppet::Parser::Functions
  newfunction(
    :pakiti_send,
    :type => :rvalue,
    :arity => 6,
    :doc => <<-EOS
...
    EOS
  ) do |args|

    servers, path, params, packages, ssl_verify, debug = args

    post_packages = ''
    packages.each do |p|
      pkg = [ p['name'] ]
      pkg << (p.has_key?('version') ? p['version'] : '')
      pkg << (p.has_key?('release') ? p['release'] : '')
      pkg << (p.has_key?('arch')    ? p['arch']    : '')
      post_packages += pkg.collect{ |i| "'#{i}'" }.join(' ') + "\n"
    end

    params['pkgs'] = post_packages

    # Ruby 1.x sucks
    uri = URI.parse("https://#{servers[0]}#{path}")

    if debug
      Puppet.warning("pakiti_send(): Sending POST on #{uri.to_s} "+
                     "with parameters "+PSON.generate(params))
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true 
    if not ssl_verify
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(params)

    begin
      response = http.start {|h| h.request(request) }

      if debug
        Puppet.warning("pakiti_send(): Received server response "+
                       "code #{response.code} (body: '#{response.body}')")
      end

      case response
        when Net::HTTPSuccess
          return ''
        else
          return response.body
      end
    rescue Exception => e
      return e.message
    end
  end
end

# vim: set ts=2 sw=2 et :
