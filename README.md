# fluent-plugin-filter-cef

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-filter-cef.svg)](https://badge.fury.io/rb/fluent-plugin-filter-cef)
[![Build Status](https://travis-ci.org/lunardial/fluent-plugin-filter-cef.svg?branch=master)](https://travis-ci.org/lunardial/fluent-plugin-filter-cef)
[![Maintainability](https://api.codeclimate.com/v1/badges/9dc37fceb1caff2c0070/maintainability)](https://codeclimate.com/github/lunardial/fluent-plugin-filter-cef/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/lunardial/fluent-plugin-filter-cef/badge.svg?branch=master)](https://coveralls.io/github/lunardial/fluent-plugin-filter-cef?branch=master)
[![downloads](https://img.shields.io/gem/dt/fluent-plugin-filter-cef.svg)](https://rubygems.org/gems/fluent-plugin-filter-cef)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

Fluentd Filter plugin to parse CEF - Common Event Format

## Requirements

| fluent-plugin-filter-cef  | fluentd | ruby |
|---------------------------|---------|------|
| >= 1.0.0 | >= v0.14.0 | >= 2.1 |

## Installation

Add this line to your application's Gemfile:

```bash
# for fluentd v0.12
gem install fluent-plugin-filter-cef -v "< 1.0.0"

# for fluentd v0.14 or higher
gem install fluent-plugin-filter-cef

# for td-agent2
td-agent-gem install fluent-plugin-filter-cef -v "< 1.0.0"

# for td-agent3
td-agent-gem install fluent-plugin-filter-cef
```

## Usage

```
<filter **>
  @type cef
  # message_key message
  # reserve_data false
  # cef_version 0
  # parse_strict_mode true
  # cef_keyfilename 'config/cef_version_0_keys.yaml'
</filter>
```

## parameters

* `message_key` (default: message)

  the key to parse the CEF message from

* `reserve_data` (default: false)

  whether or not keep the raw CEF message once parsed or not

* `cef_version` (default: 0)

  CEF version, this should be 0

* `parse_strict_mode` (default: true)

  if the CEF extensions are the following, the value of the key cs2 should 'foo hoge=fuga'

  - cs1=test cs2=foo hoge=fuga cs3=bar

  if parse_strict_mode is false, this is raugh parse, so the value of the key cs2 become 'foo' and non CEF key 'hoge' shown, and the value is 'fuga'

* `cef_keyfilename` (default: 'config/cef_version_0_keys.yaml')

  used when parse_strict_mode is true, this is the array of the valid CEF keys

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
