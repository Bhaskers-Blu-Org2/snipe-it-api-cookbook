include SnipeIT::API

resource_name :manufacturer

property :url, String, default: node['snipeit']['api']['instance']
property :token, String, required: true
property :manufacturer, String, name_property: true
property :website, String

default_action :create

load_current_value do |new_resource|
  url = Endpoint.new(new_resource.url)
  response = Get.new(url.manufacturers_endpoint, new_resource.token).response

  if record_exists?(response, new_resource.manufacturer)
    manufacturer = current_record(response, new_resource.manufacturer)
    manufacturer manufacturer['name']
  else
    current_value_does_not_exist!
  end
end

action :create do
  converge_if_changed :manufacturer do
    url = Endpoint.new(new_resource.url)
    converge_by("created #{new_resource} in Snipe-IT") do
      http_request "create #{new_resource}" do
        headers authorization_headers(new_resource.token)
        message({
          name: new_resource.manufacturer,
          url: new_resource.website,
        }.to_json)
        url url.manufacturers_endpoint
        action :post
      end
    end
  end
end
