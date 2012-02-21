module DeviceViewMethods

  def should_have_only_owned_device(device)
    json = JSON.parse(page.source)
    should_have_device(device, json.first)
    should_not_have_not_owned_devices
  end

  def should_have_device(device, json)
    json = Hashie::Mash.new json
    json.uri.should == device.uri
    json.id.should == device.id.as_json
    json.name.should == device.name
    json.type.uri.should == device.type_uri
    json.properties.each_with_index do |property, index|
      property.uri.should == device.device_properties[index].uri
      property.value.should == device.device_properties[index].value
    end
    json.physical.uri.should == device.device_physicals.first.uri
  end

  def should_not_have_not_owned_devices
    json = JSON.parse(page.source)
    json.should have(1).item
    Device.all.should have(2).items
  end

end

RSpec.configuration.include DeviceViewMethods
