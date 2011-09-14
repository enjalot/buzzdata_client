require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Buzzdata
  describe Buzzdata do
    describe '#initialize' do
      def fixture_path(fixture)
        File.expand_path File.dirname(__FILE__) + '/fixtures/' + fixture
      end

      it 'should use custom configuration file' do
        client = Buzzdata.new nil, :config_file => fixture_path('custom.yml')
        client.instance_variable_get('@api_key').should == 'dummy'
      end

      it "should not raise an error if the configuration file is default and missing" do
        expect{Buzzdata.new nil}.not_to raise_error(Buzzdata::Error, /No such file or directory/)
      end

      it "should raise an error if the configuration file is custom and missing" do
        expect{Buzzdata.new nil, :config_file => fixture_path('non_existent.yml')}.to raise_error(Buzzdata::Error, /No such file or directory/)
      end

      it "should raise an error if the configuration file is unreadable" do
        File.open(fixture_path('unreadable.yml'), 'w').chmod(0000) unless File.exist? fixture_path('unreadable.yml')
        expect{Buzzdata.new nil, :config_file => fixture_path('unreadable.yml')}.to raise_error(Buzzdata::Error, /Permission denied/)
      end

      it "should raise an error if the configuration file is invalid YAML" do
        expect{Buzzdata.new nil, :config_file => fixture_path('invalid_yaml.yml')}.to raise_error(Buzzdata::Error, /invalid YAML/)
      end

      it "should raise an error if the configuration file is not a Hash" do
        expect{Buzzdata.new nil, :config_file => fixture_path('not_a_hash.yml')}.to raise_error(Buzzdata::Error, /not a Hash/)
      end

      it "should raise an error if the API key is missing from the configuration file" do
        expect{Buzzdata.new nil, :config_file => fixture_path('missing_api_key.yml')}.to raise_error(Buzzdata::Error, /API key missing/)
        
      end
    end
  end
end
