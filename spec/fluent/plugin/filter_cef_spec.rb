require 'spec_helper'
require 'fluent/plugin/filter_cef'
require 'fluent/test'
require 'fluent/test/driver/filter'

describe Fluent::Plugin::CommonEventFormatFilter do
  DEFAULT_CONFIG = %[
    key_name message
    reserve_data false
    cef_version  0
    parse_strict_mode  true
    cef_keyfilename  'config/cef_version_0_keys.yaml'
  ]
  def create_driver(conf=DEFAULT_CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::CommonEventFormatFilter).configure(conf)
  end

  before :all do
    Fluent::Test.setup
  end

  before :each do
    @test_driver = create_driver
  end

  describe "#filter(tag, time, record)" do

    context "text == nil" do
      let (:record) { { 'message' => nil } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq nil }
    end
    context "text is empty string" do
      let (:record) { { 'message' => '' } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq nil }
    end
    context "text is not CEF" do
      let (:record) { { 'message' => 'message' } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq({ "message" => "message" }) }
    end
    context "text is CEF" do
      let (:record) { { 'message' => 'CEF:0|Vendor|Product|Version|ID|Name|Severity|cs1=test' } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq({
        "cef_version" => "0",
        "cef_device_vendor" => "Vendor",
        "cef_device_product" => "Product",
        "cef_device_version" => "Version",
        "cef_device_event_class_id" => "ID",
        "cef_name" => "Name",
        "cef_severity" => "Severity",
        "cs1" => "test" }) }
    end
    context "text is CEF (CEF Extension field is empty)" do
      let (:record) { { 'message' => 'CEF:0|Vendor|Product|Version|ID|Name|Severity|' } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq({
        "cef_version" => "0",
        "cef_device_vendor" => "Vendor",
        "cef_device_product" => "Product",
        "cef_device_version" => "Version",
        "cef_device_event_class_id" => "ID",
        "cef_name" => "Name",
        "cef_severity" => "Severity" })}
    end
    context "text is CEF (there is only one valid key in the CEF Extension field), Strict mode on" do
      let (:record) { { 'message' => 'CEF:0|Vendor|Product|Version|ID|Name|Severity|cs1=test' } }
      subject do
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq({
        "cef_version" => "0",
        "cef_device_vendor" => "Vendor",
        "cef_device_product" => "Product",
        "cef_device_version" => "Version",
        "cef_device_event_class_id" => "ID",
        "cef_name" => "Name",
        "cef_severity" => "Severity",
        "cs1" => "test" })}
    end
    context "text is CEF (there is only one valid key in the CEF Extension field), Strict mode off" do
      let (:config) {%[
        parse_strict_mode  false
      ]}
      let (:record) { { 'message' => 'CEF:0|Vendor|Product|Version|ID|Name|Severity|foo=bar' } }
      subject do
        @test_driver = create_driver(config)
        @test_driver.instance.filter(nil, nil, record)
      end
      it { is_expected.to eq({
        "cef_version" => "0",
        "cef_device_vendor" => "Vendor",
        "cef_device_product" => "Product",
        "cef_device_version" => "Version",
        "cef_device_event_class_id" => "ID",
        "cef_name" => "Name",
        "cef_severity" => "Severity",
        "foo" => "bar" })}
    end
    # context "CEF message is UTF-8, with BOM" do
    #   let (:record) { { 'message' => '***CEF:0|Vendor|Product|Version|ID|Name|Severity|cs1=test' } }
    #   subject do
    #     record['message'].setbyte(29, 0xef)
    #     record['message'].setbyte(30, 0xbb)
    #     record['message'].setbyte(31, 0xbf)
    #     record['message'].force_encoding("ascii-8bit")
    #     @test_driver.instance.filter(nil, nil, record)
    #   end
    #   it { is_expected.to eq({
    #     "cef_version" => "0",
    #     "cef_device_vendor" => "Vendor",
    #     "cef_device_product" => "Product",
    #     "cef_device_version" => "Version",
    #     "cef_device_event_class_id" => "ID",
    #     "cef_name" => "Name",
    #     "cef_severity" => "Severity",
    #     "cs1" => "test" })}
    # end
    # context "CEF message is UTF-8, but includes invalid UTF-8 string" do
    #   let (:record) { { 'message' => 'CEF:0|Vendor|Product|Version|ID|Name|Severity|src=192.168.1.1 spt=60000 dst=172.16.100.100 dpt=80 msg=\xe3\x2e\x2e\x2e' } }
    #   subject do
    #     @test_driver.instance.filter(nil, nil, record)
    #   end
    #   it { is_expected.to eq({
    #     "cef_version" => "0",
    #     "cef_device_vendor" => "Vendor",
    #     "cef_device_product" => "Product",
    #     "cef_device_version" => "Version",
    #     "cef_device_event_class_id" => "ID",
    #     "cef_name" => "Name",
    #     "cef_severity" => "Severity",
    #     "src" => "192.168.1.1",
    #     "spt" => "60000",
    #     "dst" => "172.16.100.100",
    #     "dpt" => "80",
    #     "msg" => "\xe3\x2e\x2e\x2e".scrub('?') })}
    # end
  end
end
