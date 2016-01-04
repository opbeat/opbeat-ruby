module Opbeat
  module Injections
    module NetHTTP
      class Injector
        def install
          Net::HTTP.class_eval do
            alias request_without_opb request

            def request req, body = nil, &block
              host, port = req['host'] && req['host'].split(':')
              method = req.method
              path = req.path
              scheme = use_ssl? ? 'https' : 'http'

              # inside a session
              host ||= self.address
              port ||= self.port

              extra = {
                scheme: scheme,
                port: port,
                path: path
              }

              signature = "#{method} #{host}"
              kind = "ext.net_http.#{method}"

              Opbeat.trace signature, kind, nil, extra do
                request_without_opb(req, body, &block)
              end
            end
          end
        end
      end
    end

    register 'Net::HTTP', 'net/http', NetHTTP::Injector.new
  end
end
