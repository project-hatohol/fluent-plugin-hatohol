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

require "json"
require "bunny"

module Fluent
  class HatoholOutput < BufferedOutput
    Plugin.register_output("hatohol", self)

    config_param :url, :string, :default => nil
    config_param :queue_name, :string
    config_param :tls_cert, :string, :default => nil
    config_param :tls_key, :string, :default => nil
    config_param :tls_ca_certificates, :array, :default => []

    def configure(conf)
      super
      validate_configuraiton
    end

    def start
      super
      options = {
        :tls_cert            => @tls_cert,
        :tls_key             => @tls_key,
        :tls_ca_certificates => @tls_ca_certificates,
      }
      @connection = Bunny.new(url || {}, options)
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(@queue_name)
    end

    def shutdown
      super
      @connection.close
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |tag, time, record|
        @queue.publish(JSON.generate(record),
                       :content_type => "application/json")
      end
    end

    private
    def validate_configuraiton
      if @queue_name.nil?
        raise ConfigError, "Must set queue_name"
      end
    end
  end
end
