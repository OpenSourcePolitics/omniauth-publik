# frozen_string_literal: true

require "spec_helper"
require "byebug"

describe OmniAuth::Strategies::Publik do
  subject do
    strategy
  end

  let(:access_token) { instance_double("AccessToken", options: {}) }
  let(:parsed_response) { instance_double("ParsedResponse") }
  let(:response) { instance_double("Response", parsed: parsed_response) }
  let(:strategy) do
    described_class.new(
        app,
        "CLIENT_ID",
        "CLIENT_SECRET",
        "https://connexion.publik.love"
    )
  end
  let(:app) do
    lambda do |_env|
      [200, {}, ["Hello."]]
    end
  end
  let(:raw_info_hash) do
    {
        "name" => "Foo Bar",
        "email" => "foo@example.com",
        "nickname" => "Foo Bar",
        "image" => "http://example.org/avatar.jpeg"
    }
  end

  before do
    allow(strategy).to receive(:access_token).and_return(access_token)
  end

  describe "client options" do
    it "has the correct site" do
      expect(subject.client.site).to eq("https://connexion.publik.love")
    end

    it "has the correct authorize url" do
      expect(subject.client.options[:authorize_url]).to eq("https://connexion.publik.love/idp/oidc/authorize")
    end

    it "has the correct token url" do
      expect(subject.client.options[:token_url]).to eq("https://connexion.publik.love/idp/oidc/token")
    end
  end

  describe "#callback_url" do
    it "is a combination of host, script name, and callback path" do
      allow(strategy).to receive(:full_host).and_return("https://example.com")
      allow(strategy).to receive(:script_name).and_return("/sub_uri")

      expect(subject.callback_url).to eq("https://example.com/users/auth/decidim/callback")
    end
  end

  describe "info" do
    before do
      allow(strategy).to receive(:raw_info).and_return(raw_info_hash)
    end

    it "returns the nickname" do
      expect(subject.info[:nickname]).to eq(raw_info_hash["nickname"])
    end

    it "returns the name" do
      expect(subject.info[:name]).to eq(raw_info_hash["name"])
    end

    it "returns the email" do
      expect(subject.info[:email]).to eq(raw_info_hash["email"])
    end

    it "returns the image" do
      expect(subject.info[:image]).to eq(raw_info_hash["image"])
    end
  end
end
