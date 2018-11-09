require 'spec_helper'

describe 'snipeit_api::asset - create action' do
  step_into :asset

  context 'when the asset exists' do
    recipe do
      asset 'asset exists' do
        machine_name 'Magic-Machine'
        serial_number 'W80123456789'
        status 'Pending'
        model 'MacPro4,1'
        token chef_vault_item('snipe-it', 'api')['key']
        url node['snipeit']['api']['instance']
      end
    end

    it { is_expected.to_not post_http_request('create asset[1234567]') }
  end

  context 'when the asset does not exist' do
    recipe do
      asset 'create a machine' do
        machine_name 'Does Not Exist'
        asset_tag '0000000'
        serial_number 'W81123456789'
        model 'MacPro4,1'
        location 'Building 1'
        token chef_vault_item('snipe-it', 'api')['key']
        url node['snipeit']['api']['instance']
      end
    end

    message = {
      rtd_location_id: 1,
      name: 'Does Not Exist',
      asset_tag: '0000000',
      serial: 'W81123456789',
      status_id: 1,
      model_id: 4,
    }

    it {
      is_expected.to post_http_request('create Does Not Exist')
        .with(
          url: hardware_endpoint,
          message: message.to_json,
          headers: headers
        )
    }
  end

  context 'when the location does not exist' do
    recipe do
      asset 'creating asset' do
        machine_name 'Does Not Exist'
        serial_number 'C0123456789'
        status 'Pending'
        model 'MacPro4,1'
        location 'Building 42'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_error(Location::DoesNotExistError)
    end
  end

  context 'when the status label, and model does not exist in the database' do
    recipe do
      asset 'creating asset' do
        machine_name 'Does Not Exist'
        serial_number 'C0123456789'
        status 'Recycled'
        model 'MacPro4,1'
        location 'Building 1'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_error(Status::DoesNotExistError)
    end
  end

  context 'when the model does not exist' do
    recipe do
      asset 'creating asset' do
        machine_name 'Does Not Exist'
        serial_number 'C0123456789'
        status 'Pending'
        model 'MacPro6,1'
        location 'Building 1'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_error(Model::DoesNotExistError)
    end
  end
end
