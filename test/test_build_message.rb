# Copyright (C) 2014 Project Hatohol
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

class BuildMessageTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def parse_config(config)
    use_v1 = true
    config_string = <<-CONFIG
      type hatohol
      queue_name gate.1
    CONFIG
    config.each do |key, value|
      config_string << "#{key} #{value}\n"
    end
    Fluent::Config.parse(config_string, "(test)", "(test_dir)", use_v1)
  end

  def create_plugin(config)
    plugin = Fluent::HatoholOutput.new
    plugin.configure(parse_config(config))
    plugin
  end

  def call_build_message(config, tag, time, record)
    create_plugin(config).send(:build_message, tag, time, record)
  end

  sub_test_case("host") do
    def build_host(config, record)
      record["message"] = "Message"
      message = call_build_message(config,
                                   "hatohol.syslog.messages",
                                   Fluent::Engine.now,
                                   record)
      message["body"]["hostName"]
    end

    def test_default
      assert_equal("www.example.com",
                   build_host({}, {"host" => "www.example.com"}))
    end

    def test_custom
      assert_equal("www.example.com",
                   build_host({
                                "host_key" => "hostname",
                              },
                              {"hostname" => "www.example.com"}))
    end
  end

  sub_test_case("content") do
    def build_content(config, record)
      record["host"] ||= "www.example.com"
      message = call_build_message(config,
                                   "hatohol.syslog.messages",
                                   Fluent::Engine.now,
                                   record)
      message["body"]["content"]
    end

    def test_default
      assert_equal("Message",
                   build_content({}, {"message" => "Message"}))
    end

    def test_multiple
      assert_equal("Message at www.example.com",
                   build_content({
                                   "content_format" => "%{message} at %{host}",
                                 },
                                 {
                                   "host" => "www.example.com",
                                   "message" => "Message",
                                 }))
    end
  end

  sub_test_case("severity") do
    def build_severity(config, record)
      record["host"] ||= "www.example.com"
      record["message"] ||= "Error!"
      message = call_build_message(config,
                                   "hatohol.syslog.messages",
                                   Fluent::Engine.now,
                                   record)
      message["body"]["severity"]
    end

    def test_default
      assert_equal("error",
                   build_severity({}, {}))
    end

    def test_constatnt
      assert_equal("warning",
                   build_severity({"severity_format" => "warning"},
                                  {}))
    end

    def test_parameter
      assert_equal("critical",
                   build_severity({"severity_format" => "%{severity}"},
                                  {"severity" => "critical"}))
    end
  end
end
