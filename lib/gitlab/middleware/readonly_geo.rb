module Gitlab
  module Middleware
    class ReadonlyGeo
      DISALLOWED_METHODS = %w(POST PATCH PUT DELETE)

      def initialize(app)
        @app = app
      end

      def call(env)
        @env = env

        if disallowed_request? && Gitlab::Geo.readonly?
          Rails.logger.debug('Gitlab Geo: preventing possible non readonly operation')

          rack_flash.alert = 'You cannot do writing operations on a readonly Gitlab Geo instance'
          rack_session['flash'] = rack_flash.to_session_value

          return [301, { 'Location' => last_visited_url }, []]
        end

        @app.call(env)
      end

      private

      def disallowed_request?
        DISALLOWED_METHODS.include?(@env['REQUEST_METHOD']) && !logout_route
      end

      def rack_flash
        @rack_flash ||= ActionDispatch::Flash::FlashHash.from_session_value(rack_session)
      end

      def rack_session
        @env['rack.session']
      end

      def request
        @request ||= Rack::Request.new(@env)
      end

      def last_visited_url
        @env['HTTP_REFERER'] || rack_session['user_return_to'] || @app.url_helpers.root_url
      end

      def route_hash
        @route_hash ||= Rails.application.routes.recognize_path(request.url, { method: request.request_method }) rescue {}
      end

      def logout_route
        route_hash[:controller] == 'sessions' && route_hash[:action] == 'destroy'
      end
    end
  end
end
