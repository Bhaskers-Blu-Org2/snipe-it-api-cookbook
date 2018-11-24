categories = {
  'macOS - Desktop' => 'asset',
  'macOS - Portable' => 'asset',
}

api_token = node['snipeit']['api']['token']
url = node['snipeit']['api']['instance']

manufacturer 'Apple' do
  website 'https://www.apple.com'
  token api_token
  url url
end

categories.each do |name, type|
  category name do
    category_type type
    token api_token
    url url
  end
end

model 'Mac Pro (Early 2009)' do
  manufacturer 'Apple'
  category 'macOS - Desktop'
  model_number 'MacPro4,1'
  token api_token
  url url
end

asset 'create an asset' do
  serial_number 'HALAEK123123'
  model 'MacPro4,1'
  token api_token
  url url
end

location 'Building 1' do
  address '1 Company Lane'
  city 'San Francisco'
  state 'CA'
  zip '94130'
  token api_token
  url url
end
