require 'spec_helper'

describe 'snipeit_api::model' do
  step_into :model

  before do
    stub_request(:get, "#{category_endpoint}?search=Windows%20-%20Desktop")
      .to_return(
        body: {
          total: 1,
          rows: [
            {
              id: 3,
              name: 'Windows - Desktop',
              category_type: 'asset',
            },
          ],
        }.to_json
      )
  end

  context 'when the model does exist' do
    recipe do
      model 'Mac Pro (Early 2009)' do
        manufacturer 'Apple'
        category 'macOS - Desktop'
        model_number 'MacPro4,1'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it { is_expected.to_not post_http_request('create model[MacPro4,1]') }
  end

  context 'when the model does not exist' do
    before do
      stub_request(:get, "#{model_endpoint}?search=HAL9000")
        .to_return(body: empty_response)

      stub_request(:get, "#{manufacturer_endpoint}?search=University%20of%20Illinois")
        .to_return(
          body: {
            total: 1,
            rows: [
              {
                id: 3,
                name: 'University of Illinois',
                url: 'https://www.illinois.edu',
              },
            ],
          }.to_json
        )
    end

    recipe do
      model 'HAL 9000' do
        manufacturer 'University of Illinois'
        category 'Windows - Desktop'
        model_number 'HAL9000'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it {
      is_expected.to post_http_request('create model[HAL 9000]')
        .with(
          url: model_endpoint,
          message: {
            name: 'HAL 9000',
            model_number: 'HAL9000',
            category_id: 3,
            manufacturer_id: 3,
          }.to_json,
          headers: headers
        )
    }
  end

  context 'when the manufacturer does not exist' do
    before do
      stub_request(:get, "#{model_endpoint}?search=Altair8800")
        .to_return(body: empty_response)

      stub_request(:get, "#{manufacturer_endpoint}?search=MITS")
        .to_return(body: empty_response)
    end

    recipe do
      model 'Altair 8800' do
        manufacturer 'MITS'
        category 'Windows - Desktop'
        model_number 'Altair8800'
        token node['snipeit']['api']['token']
        url node['snipeit']['api']['instance']
      end
    end

    it 'raises an exception' do
      expect { chef_run }.to raise_error(Manufacturer::DoesNotExistError)
    end
  end
end
