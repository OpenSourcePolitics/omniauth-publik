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
        "given_name" => given_name,
        "email" => email,
        "nickname" => nickname,
    }
  end

  let(:given_name) { "Foo Bar" }
  let(:email) { "foo@example.com" }
  let(:nickname) { "BarFoo" }

  before do
    allow(strategy).to receive(:access_token).and_return(access_token)
  end

  describe "client options" do
    it "has the correct site" do
      expect(subject.client.site).to eq("https://connexion.publik.love")
    end

    it "has the correct authorize url" do
      expect(subject.client.options[:authorize_url]).to eq("https://connexion.publik.love/idp/oidc/authorize/")
    end

    it "has the correct token url" do
      expect(subject.client.options[:token_url]).to eq("https://connexion.publik.love/idp/oidc/token/")
    end
  end

  describe "#callback_url" do
    before do
      allow(strategy).to receive(:full_host).and_return("https://example.com")
      allow(strategy).to receive(:script_name).and_return("/sub_uri")
    end

    it "is a combination of host, script name, and callback path" do
      expect(subject.callback_url).to eq("https://example.com/sub_uri/sub_uri/auth/publik/callback")
    end

    context "when script_name is empty" do
      before do
        allow(strategy).to receive(:script_name).and_return("")
      end

      it "build url without script name" do
        expect(subject.callback_url).to eq("https://example.com/auth/publik/callback")
      end
    end
  end

  describe "info" do
    before do
      allow(strategy).to receive(:raw_info).and_return(raw_info_hash)
    end

    it "returns the nickname" do
      expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
      expect(subject.info[:nickname]).to eq(raw_info_hash["given_name"])
      expect(subject.info[:nickname]).to eq("Foo Bar")
    end

    it "returns the name" do
      expect(subject.info[:name]).to eq(raw_info_hash["given_name"])
      expect(subject.info[:name]).to eq("Foo Bar")
    end

    it "returns the email" do
      expect(subject.info[:email]).to eq(raw_info_hash["email"])
    end

    context "when name is missing" do
      let(:given_name) { "" }

      it "returns empty" do
        expect(subject.info[:name]).to be_empty
      end
    end
  end
end
