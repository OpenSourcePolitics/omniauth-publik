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
      "preferred_username" => preferred_username,
      "family_name" => family_name
    }
  end

  let(:given_name) { "Given name" }
  let(:email) { "foo@example.com" }
  let(:nickname) { "Nickname" }
  let(:preferred_username) { "Preferred user name" }
  let(:family_name) { "Family name" }

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

    describe "[:nickname]" do
      it "returns the nickname as preferred username" do
        expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
        expect(subject.info[:nickname]).to eq(raw_info_hash["preferred_username"])
        expect(subject.info[:nickname]).to eq(preferred_username)
      end

      context "with undefined keys" do
        context "when 'preferred_username' is not defined" do
          let(:raw_info_hash) do
            {
              "given_name" => given_name,
              "email" => email,
              "nickname" => nickname,
              "family_name" => family_name
            }
          end

          it "returns the nickname as name" do
            expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
            expect(subject.info[:nickname]).to eq("#{raw_info_hash["given_name"]} #{raw_info_hash["family_name"]}")
            expect(subject.info[:nickname]).to eq("#{given_name} #{family_name}")
          end

          context "and 'given_name' is not defined" do
            let(:raw_info_hash) do
              {
                "email" => email,
                "nickname" => nickname,
                "family_name" => family_name
              }
            end

            it "returns the nickname as name" do
              expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
              expect(subject.info[:nickname]).to eq(raw_info_hash["family_name"])
              expect(subject.info[:nickname]).to eq(family_name)
            end

            context "and 'family_name' is not defined" do
              let(:raw_info_hash) do
                {
                  "email" => email,
                  "nickname" => nickname
                }
              end

              it "returns empty" do
                expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
                expect(subject.info[:nickname]).to be_empty
              end
            end
          end
        end
      end

      context "with empty keys" do
        context "when 'preferred_username' is empty" do
          let(:preferred_username) { "" }

          it "returns the nickname as name" do
            expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
            expect(subject.info[:nickname]).to eq("#{raw_info_hash["given_name"]} #{raw_info_hash["family_name"]}")
            expect(subject.info[:nickname]).to eq("#{given_name} #{family_name}")
          end

          context "and 'given_name' is empty" do
            let(:given_name) { "" }

            it "returns the nickname as name" do
              expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
              expect(subject.info[:nickname]).to eq(raw_info_hash["family_name"])
              expect(subject.info[:nickname]).to eq(family_name)
            end

            context "and 'family_name' is empty" do
              let(:family_name) { "" }

              it "returns empty" do
                expect(subject.info[:nickname]).not_to eq(raw_info_hash["nickname"])
                expect(subject.info[:nickname]).to be_empty
              end
            end
          end
        end
      end
    end

    describe "[:name]" do
      it "returns the name" do
        expect(subject.info[:name]).to eq("#{raw_info_hash["given_name"]} #{raw_info_hash["family_name"]}")
        expect(subject.info[:name]).to eq("#{given_name} #{family_name}")
      end

      context "with undefined keys" do
        context "when 'given_name' is not defined" do
          let(:raw_info_hash) do
            {
              "email" => email,
              "nickname" => nickname,
              "preferred_username" => preferred_username,
              "family_name" => family_name
            }
          end

          it "returns family name" do
            expect(subject.info[:name]).to eq(raw_info_hash["family_name"])
            expect(subject.info[:name]).to eq(family_name)
          end

          context "and 'family_name' is not defined" do
            let(:raw_info_hash) do
              {
                "email" => email,
                "nickname" => nickname,
                "preferred_username" => preferred_username
              }
            end

            it "returns empty" do
              expect(subject.info[:name]).to be_empty
            end
          end
        end

        context "when 'family_name' is not defined" do
          let(:raw_info_hash) do
            {
              "given_name" => given_name,
              "email" => email,
              "nickname" => nickname,
              "preferred_username" => preferred_username
            }
          end

          it "returns the 'given_name'" do
            expect(subject.info[:name]).to eq(raw_info_hash["given_name"])
            expect(subject.info[:name]).to eq(given_name)
          end
        end
      end

      context "when keys are empty" do
        context "when 'given_name' is empty" do
          let(:given_name) { "" }

          it "returns family name" do
            expect(subject.info[:name]).to eq(raw_info_hash["family_name"])
            expect(subject.info[:name]).to eq(family_name)
          end

          context "and 'family_name' is empty" do
            let(:family_name) { "" }

            it "returns empty" do
              expect(subject.info[:name]).to be_empty
            end
          end
        end

        context "when 'family_name' is empty" do
          let(:family_name) { "" }

          it "returns the 'given_name'" do
            expect(subject.info[:name]).to eq(raw_info_hash["given_name"])
            expect(subject.info[:name]).to eq(given_name)
          end
        end
      end
    end

    describe "[:email]" do
      it "returns the email" do
        expect(subject.info[:email]).to eq(raw_info_hash["email"])
      end

      context "when 'email' is not defined" do
        let(:raw_info_hash) do
          {
            "given_name" => given_name,
            "nickname" => nickname,
            "preferred_username" => preferred_username,
            "family_name" => family_name
          }
        end

        it "returns empty" do
          expect(subject.info[:email]).to be_empty
        end
      end

      context "when 'email' is empty" do
        let(:email) { "" }

        it "returns empty" do
          expect(subject.info[:email]).to be_empty
        end
      end
    end
  end
end
