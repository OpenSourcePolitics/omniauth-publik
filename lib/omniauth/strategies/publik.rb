# frozen_string_literal: true

require "omniauth-oauth2"
require "open-uri"

module OmniAuth
  module Strategies
    class Publik < OmniAuth::Strategies::OAuth2
      args [:client_id, :client_secret, :site]

      option :name, :publik
      option :site, nil
      option :client_options, {}

      uid do
        raw_info["sub"]
      end

      info do
        {
          email: raw_info["email"],
          nickname: parse_nickname,
          name: parse_name
        }
      end
      
      def parse_name
	      "#{raw_info["given_name"]} #{raw_info["family_name"]}".strip
      end
      
      def parse_nickname
        return parse_name if raw_info["preferred_username"].nil? || raw_info["preferred_username"].empty?

        raw_info["preferred_username"]
      end

      def client
        options.client_options[:site] = options.site
        options.client_options[:authorize_url] = URI.join(options.site, "/idp/oidc/authorize/").to_s
        options.client_options[:token_url] = URI.join(options.site, "/idp/oidc/token/").to_s
        super
      end

      def raw_info
	@raw_info ||= access_token.get("/idp/oidc/user_info/").parsed
      end

      # https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
