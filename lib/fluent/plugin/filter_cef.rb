require 'fluent/log'
require 'fluent/plugin/filter'
require 'yaml'

module Fluent::Plugin
  class CommonEventFormatFilter < Filter
    Fluent::Plugin.register_filter("cef", self)

    helpers :record_accessor

    config_param :key_name, :string, default: 'message'
    config_param :reserve_data, :bool, default: false
    config_param :cef_version, :integer, :default => 0
    config_param :parse_strict_mode, :bool, :default => true
    config_param :cef_keyfilename, :string, :default => 'config/cef_version_0_keys.yaml'

    def configure(conf)
      super

      @key_value_format_regexp = /([^\s=]+)=(.*?)(?:(?=[^\s=]+=)|\z)/
      @valid_format_regexp = create_valid_format_regexp
      @accessor = record_accessor_create(@key_name)

      begin
        if @parse_strict_mode
          if @cef_keyfilename =~ /^\//
            yaml_fieldinfo = YAML.load_file(@cef_keyfilename)
          else
            yaml_fieldinfo = YAML.load_file("#{File.dirname(File.expand_path(__FILE__))}/#{@cef_keyfilename}")
          end
          @keys_array = []
          yaml_fieldinfo.each {|_key, value| @keys_array.concat(value) }
          $log.info "running with strict mode, #{@keys_array.length} keys are valid."
        else
          $log.info "running without strict mode"
        end
      rescue => e
        @parse_strict_mode = false
        $log.warn "running without strict mode because of the following error"
        $log.warn "#{e.message}"
      end
    end

    def filter(tag, time, record)
      raw_value = @accessor.call(record)

      if raw_value.nil? || raw_value.empty?
        return nil
      end

      raw_value.force_encoding("utf-8")
      replaced_text = raw_value.scrub('?')
      new_record = record.dup
      record_overview = @valid_format_regexp.match(replaced_text)

      if record_overview.nil?
        return record
      end

      begin
        record_overview.names.each {|key| new_record[key] = record_overview[key] }
        text_cef_extension = record_overview["cef_extension"]
        new_record.delete("cef_extension")
      rescue
        return record
      end

      unless text_cef_extension.nil?
        record_cef_extension = parse_cef_extension(text_cef_extension)
        new_record.merge!(record_cef_extension)
      end

      new_record.delete(@key_name) unless @reserve_data

      new_record
    end

    private

    def create_valid_format_regexp
      cef_header = /
          CEF:(?<cef_version>#{@cef_version})\|
          (?<cef_device_vendor>[^|]*)\|
          (?<cef_device_product>[^|]*)\|
          (?<cef_device_version>[^|]*)\|
          (?<cef_device_event_class_id>[^|]*)\|
          (?<cef_name>[^|]*)\|
          (?<cef_severity>[^|]*)
        /x
      valid_format_regexp = /
            \A
              #{cef_header}\|
              (?<cef_extension>.*)
            \z
          /x

      Regexp.new(valid_format_regexp)
    end

    def parse_cef_extension(text)
      if @parse_strict_mode == true
        parse_cef_extension_with_strict_mode(text)
      else
        parse_cef_extension_without_strict_mode(text)
      end
    end

    def parse_cef_extension_with_strict_mode(text)
      record = {}

      begin
        last_valid_key_name = nil
        text.scan(@key_value_format_regexp) do |key, value|
          if @keys_array.include?(key)
            record[key] = value
            record[last_valid_key_name].rstrip! unless last_valid_key_name.nil?
            last_valid_key_name = key
          else
            record[last_valid_key_name].concat("#{key}=#{value}")
          end
        end
      rescue
        return {}
      end

      record
    end

    def parse_cef_extension_without_strict_mode(text)
      record = {}

      begin
        text.scan(@key_value_format_regexp) {|key, value| record[key] = value.rstrip }
      rescue
        return {}
      end

      record
    end
  end
end
