require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "PropertiesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { Pending.destroy_all }
  before { History.destroy_all }
  before { Device.destroy_all }


  # PUT /devices/{device-id}/properties
  context ".update" do
    before { @resource = Factory(:device_complete) }
    before { @not_owned_resource = Factory(:not_owned_device) }
    before { @pending = Factory(:pending_complete) }
    before { @uri = "#{host}/devices/#{@resource.id}/properties" }

    it_should_behave_like "protected resource", "page.driver.put(@uri)"


    context "when logged in" do
      before { basic_auth(@user) } 
      let(:params) {{ properties: new_device_properties }}


      context "with a connected physical" do
        context "when update all properties" do
          before { page.driver.put(@uri, params.to_json) }


          scenario "shoul update device properties with physical response" do
            page.status_code.should == 200
            page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
            page.should have_content("\"#{Settings.properties.status.new_value}\"")
            should_have_valid_json(page.body)
          end


          context "with created history resource" do
            before { @history = History.first }
            before { visit "#{host}/devices/#{@resource.id}/histories" }
            scenario "represent new properties values" do
              should_have_history @history
              page.should have_content("\"#{Settings.properties.intensity.new_value}\"")
              page.should have_content("\"#{Settings.properties.status.new_value}\"")
            end
          end
        end


        describe "pending" do
          context "when update all properties" do
            let(:params) {{ properties: new_device_properties }}
            before { page.driver.put(@uri, params.to_json) }
            it { @pending.reload.pending_status.should == false }
            scenario "close all pending properties" do
              page.should_not have_content "\"pending\": true"
            end
          end


          context "when update one property" do
            let(:params) {{ properties: [new_device_properties.first] }}
            before { page.driver.put(@uri, params.to_json) }
            it { @pending.reload.pending_status.should == true }
            scenario "close one pending property" do
              page.should have_content "\"pending\": true"
            end
            scenario "leave open one pending property" do
              page.should have_content "\"pending\": false"
            end
          end


          context "when update no properties" do
            let(:params) {{ properties: [] }}
            before { page.driver.put(@uri, params.to_json) }
            it { @pending.reload.pending_status.should == true }
            scenario "leave open all pending properties" do
              page.should_not have_content "\"pending\": false"
            end
          end
        end
      end
    end
  end
end