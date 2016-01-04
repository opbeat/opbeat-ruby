module Opbeat
  class ErrorMessage
    class User < Struct.new(:is_authenticated, :id, :username, :email)
      def self.from_rack_env config, env
        controller = env['action_controller.instance']
        method = config.current_user_method.to_sym

        return unless controller && controller.respond_to?(method)

        user = controller.send method

        new(
          true,
          user.respond_to?(:id) && user.id,
          user.respond_to?(:username) && user.username,
          user.respond_to?(:email) && user.email
        )
      end
    end
  end
end
