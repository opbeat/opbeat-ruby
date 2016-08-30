module Opbeat
  class ErrorMessage
    class HTTP < Struct.new(:url, :method, :data, :query_string, :cookies,
                            :headers, :remote_host, :http_host, :user_agent,
                            :secure, :env)

      HTTP_ENV_KEY = /^HTTP_/.freeze
      UNDERSCORE = "_".freeze
      DASH = "-".freeze
      QUESTION = "?".freeze

      def self.from_rack_env env, opts = {}
        if env.is_a?(ActionDispatch::Request)
          req = env
        else
          req = Rack::Request.new env
        end

        http = new(
          req.url.split(QUESTION).first,               # url
          req.request_method,                          # method
          nil,                                         # data
          req.query_string,                            # query string
          env['HTTP_COOKIE'],                          # cookies
          {},                                          # headers
          req.ip,                                      # remote host
          req.host_with_port,                          # http host
          req.user_agent,                              # user agent
          req.scheme == 'https'.freeze ? true : false, # secure
          {}                                           # env
        )

        # In Rails < 5 ActionDispatch::Request inherits from Hash
        headers = env.respond_to?(:headers) ? env.headers : env

        headers.each do |k, v|
          next unless k.upcase == k # lower case stuff isn't relevant

          if k.match(HTTP_ENV_KEY)
            header = k.gsub(HTTP_ENV_KEY, '')
              .split(UNDERSCORE).map(&:capitalize).join(DASH)
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

        if filter = opts[:filter]
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
