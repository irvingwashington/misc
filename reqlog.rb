require 'net/http'
module ReqLog

  def self.hack_net_http_request!(opts={})
    dest_dir = opts[:dest_dir] || "/tmp"
    klass = Net::HTTP
    unless klass.method_defined?(:request_without_logging)
      klass.send(:alias_method, :request_without_logging, :request)
    end

    klass.send(:define_method, :request) do |req, body=nil, &block|

      t = Time.now
      name_with_path = File.join(dest_dir, "log_request_#{[t.day,t.month,t.year].join("_")}_#{t.to_f}.txt")
      File.open(name_with_path, "w") do |f|
        f.puts("------>>>> Request >>")
        f.puts("Request start: #{t}")
        f.puts("#{req.method.upcase} #{@address}:#{@port}#{['/',req.path].uniq.join}")
        f.puts("Headers:")
        req.each_header { |k,v| f.puts("  #{k}: #{v}") }
        f.puts("\nBody: ", body ? body.force_encoding("UTF-8") : "(empty)")
        f.puts("<<<<<----- Response --")
        request_without_logging(req, body, &block).tap do |response|
          f.puts("Code: #{response.code}\nHeaders:")
          response.each_header { |k,v| f.puts("  #{k}: #{v}") }
          f.puts("\nBody:\n", response.body ? response.body.force_encoding("UTF-8") : "(empty)")
          f.puts("\n-------------\nTotal time: #{((Time.now.to_f - t.to_f) * 1000).round}ms")
        end

      end
    end
  end

end
ReqLog.hack_net_http_request!
