class LemonStats
	class RedisStore < LemonStats::StatsStore
		attr_reader :connection

		def initialize(id, config = {})
			config[:host] ||= '127.0.0.1'
			config[:port] ||= 6379
			config[:db] ||= 0

			super(id, :redis_store, config)		
		end

		def save_stat(stat)

			connection.pipelined do
				key = redis_key stat.group

				case stat.type.to_sym
				when :timer
					connection.hincr key, stat.name, stat.delta
				when :counter
					connection.hincr key, stat.name, stat.delta
				else 
					connection.hset key, stat.name, stat.value
				end
			end
		end

		def remove_stat(stat)
			connection.pipelined do
				key = redis_key stat.group
				connection.hdel key, stat.name
			end
		end

		def clear_stat(stat)
			connection.pipelined do
				key = redis_key stat.group
				connection.hset key, stat.name, stat.value
			end
		end

		def load_stats(group)
			key = redis_key group
		end

		def close
			connection.close
		end

		private

		def redis_key(group)
			"#{@key}:#{group}"
		end

		def connection
			if !@connection
				@connection = Redis.new(:host => config[:host], :port => config[:port], :db => config[:db])
			end

			@connection
		end

	end
end

 def update_redis(stats)
      logger.debug "Updating redis stats with: #{stats.inspect}"

      @redis.pipelined do
          stats[:timers].each_pair do |k,v|
            @redis.hincrby @redis_timers, k, v.to_i*1000 if @stats[:timers][k.to_sym]
          end

          stats[:counters].each_pair do |k,v|
            @redis.hincrby @redis_counters, k, v.to_i if @stats[:counters][k.to_sym]
          end

          stats[:gauges].each_pair do |k,v|
            @redis.hset @redis_gauges, k, v if @stats[:gauges][k.to_sym]
          end
      end
    end