require 'helper'

RSpec.describe Flipper::Api::V1::Actions::GroupsGate do
  let(:app) { build_api(flipper) }

  describe 'enable' do
    before do
      flipper[:my_feature].disable
      Flipper.register(:admins) do |actor|
        actor.respond_to?(:admin?) && actor.admin?
      end
      put '/api/v1/features/my_feature/groups/admins/enable/'
    end

    it 'enables feature for group' do
      person = double
      allow(person).to receive(:flipper_id).and_return(1)
      allow(person).to receive(:admin?).and_return(true)
      expect(last_response.status).to eq(204)
      expect(flipper[:my_feature].enabled?(person)).to be_truthy
    end
  end

  describe 'disable' do
    before do
      flipper[:my_feature].disable
      Flipper.register(:admins) do |actor|
        actor.respond_to?(:admin?) && actor.admin?
      end
      flipper[:my_feature].enable_group(:admins)
      put '/api/v1/features/my_feature/groups/admins/disable/'
    end

    it 'disables feature for group' do
      person = double
      allow(person).to receive(:flipper_id).and_return(1)
      allow(person).to receive(:admin?).and_return(true)
      expect(last_response.status).to eq(204)
      expect(flipper[:my_feature].enabled?(person)).to be_falsey
    end
  end

  describe 'non-existent feature' do
    before do
      put '/api/v1/features/some_invalid_feature_name/groups/admins/disable/'
    end

    it  '404s when feature does not exist' do
      expect(last_response.status).to eq(404)
    end
  end

  describe 'non-existent group' do
    before do
      flipper[:my_feature].disable
      put '/api/v1/features/my_feature/groups/admins/disable/'
    end

    it '404s when group not found' do
      expect(last_response.status).to eq(404)
    end
  end

  describe 'invalid action' do
    before do
      put '/api/v1/features/my_feature/groups/admins/not_valid/'
    end

    it 'returns 404' do
      expect(last_response.status).to eq(404)
    end
  end
end

