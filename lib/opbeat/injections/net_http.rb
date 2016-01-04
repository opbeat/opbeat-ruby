module Opbeat
  module Injections
    module NetHTTP
      class Injector
        def install
          Net::HTTP.class_eval do
            alias request_without_opb request

            def request req, body = nil, &block
              signature = "HTTP/#{req.method}"
              kind = "ext.net_http.#{req.method}"

              Opbeat.trace signature, kind do
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
