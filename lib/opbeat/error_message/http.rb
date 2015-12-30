module Opbeat
  class ErrorMessage
    class HTTP < Struct.new(:url, :method, :data, :query_string, :cookies,
                            :headers, :remote_host, :http_host, :user_agent,
                            :secure, :env)
      def self.from_rack_env env, filter: nil
        req = Rack::Request.new env

        http = new(
          req.url.split('?').first,             # url
          req.request_method,                   # method
          nil,                                  # data
          req.query_string,                     # query string
          env['HTTP_COOKIE'],                   # cookies
          {},                                   # headers
          req.ip,                               # remote host
          req.host_with_port,                   # http host
          req.user_agent,                       # user agent
          req.scheme == 'https' ? true : false, # secure
          {}                                    # env
        )

        env.each do |k, v|
          next unless k.upcase == k # lower case stuff isn't relevant

          if k.match(/^HTTP_/)
            header = k.gsub(/^HTTP_/, '')
              .split("_").map(&:capitalize).join('-')
            http.headers[header] = v.to_s
          else
            http.env[k] = v.to_s
          end
        end

        if req.form_data?
          http.data = req.POST
        elsif req.body
          http.data = req.body.read
          req.body.rewind
        end

        if filter
          http.apply_filter filter
        end

        http
      end

      def apply_filter filter
        self.data = filter.apply data
        self.query_string = filter.apply query_string
        self.cookies = filter.apply cookies
      end
    end
  end
end
