module Opbeat
  module Normalizers
    module ActionController
      class ProcessAction < Normalizer
        register 'process_action.action_controller'
        KIND = 'app.controller.action'.freeze

        def normalize transaction, name, payload
          transaction.endpoint = endpoint(payload)
          [transaction.endpoint, KIND, nil]
        end

        private

        def endpoint payload
          "#{payload[:controller]}##{payload[:action]}"
        end
      end
    end
  end
end
