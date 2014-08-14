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

    config_param :host, :string
    config_param :port, :integer, :default => 5672
    config_param :user, :string, :default => "guest"
    config_param :password, :string, :default => "guest"
    config_param :queue_name, :string

    def configure(conf)
      super
      validate_configuraiton
    end

    def start
      super
      options = {
        :host     => @host,
        :port     => @port,
        :user     => @user,
        :password => @password,
      }
      @connection = Bunny.new(options)
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
