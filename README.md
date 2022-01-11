# OmniAuth::Publik

This is the [Publik](https://www.publik.love/) strategy for OmniAuth. It should be used when using a Publik application as an OAuth provider.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-publik', git: 'https://github.com/OpenSourcePolitics/omniauth-publik', branch: 'v0.0.9'
```

Or using Rubygems (soon available) : 
```ruby
gem 'omniauth-publik'
```

And then execute:

    $ bundle

## Usage with Decidim

In order to implement the `omniauth-publik` library in your [Decidim](https://github.com/decidim/decidim) instance, you must create a new initializer (ex: `config/initializers/omniauth_publik.rb` )in your application with the following:

```ruby
# File: config/initializers/omniauth_publik.rb

if Rails.application.secrets.dig(:omniauth, :publik).present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(
      :publik,
      setup: ->(env) {
        request = Rack::Request.new(env)
        organization = Decidim::Organization.find_by(host: request.host)
        provider_config = organization.enabled_omniauth_providers[:publik]
        env["omniauth.strategy"].options[:client_id] = provider_config[:client_id]
        env["omniauth.strategy"].options[:client_secret] = provider_config[:client_secret]
        env["omniauth.strategy"].options[:site] = provider_config[:site_url]
      },
      scope: :public
    )
  end
end
```

Then you need to add the omniauth keys to the `config/secrets.yml` with the following: 

```yaml
  omniauth:
    publik:
      enabled: true
      client_id: <%= ENV["OMNIAUTH_PUBLIK_CLIENT_ID"] %>
      client_secret: <%= ENV["OMNIAUTH_PUBLIK_CLIENT_SECRET"] %>
      site_url: <%= ENV["OMNIAUTH_PUBLIK_SITE_URL"] %>
```

You can find more information on the [official documentation](https://docs.decidim.org/en/services/social_providers/).

## Authentication Hash

An example auth hash available in `request.env['omniauth.auth']`:

```ruby
{
  :provider => "publik",
  :uid => "123456",
  :info => {
    :nickname => "foobar",
    :name => "Foo Bar",
    :email => "foo@bar.com",
    :image => "http://www.example.org/avatar.jpeg",
  },
  :credentials => {
    :token => "a1b2c3d4...", # The OAuth 2.0 access token
    :secret => "abcdef1234"
  }
}
```

## Following our license

If you plan to release your application you'll need to publish it using the same license: GPL Affero 3. We recommend doing that on GitHub before publishing, you can read more on "[Being Open Source From Day One is Especially Important for Government Projects](http://producingoss.com/en/governments-and-open-source.html#starting-open-for-govs)". If you have any trouble you can contact us on [Gitter](https://gitter.im/OpenSourcePolitics/publik).
