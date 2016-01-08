module Opbeat
  class ErrorMessage
    class User < Struct.new(:is_authenticated, :id, :username, :email)
      CONTROLLER_KEY = 'action_controller.instance'.freeze

      def self.from_rack_env config, env
        controller = env[CONTROLLER_KEY]
        method = config.current_user_method.to_sym

        return unless controller && controller.respond_to?(method)

        user = controller.send method

        new(
          true,
          user.respond_to?(:id) ? user.id : nil,
          user.respond_to?(:username) ? user.username : nil,
          user.respond_to?(:email) ? user.email : nil
        )
      end
    end
  end
end
