class LemonStats
	class StatsStore
		attr_accessor :key
		attr_accessor :type
		attr_accessor :id
		attr_accessor :config

		VALID_ACTIONS = %w[
			save
			clear
			remove
		].freeze

		def initialize(id, type, config={}, key=nil)
			@config = config
			@type = type.to_sym
			@key = key
			@id = id
		end

		def set_key(key)
			@key = key
		end

		def close
			raise  LemonStats::Error, "No close method defined for store type: #{@type}"
		end

		def load_stats(group)
			raise  LemonStats::Error, "No load_stats method defined for store type: #{@type}"
		end

		def method_missing(method_sym, *args, &block)
			if method_sym.to_s =~ /^(.*)_stats$/
				handle_stats( $1.to_sym, args.first )
			elsif method_sym.to_s =~ /^(.*)_stat$/
				handle_stat( $1.to_sym, args.first )
			else
				super
			end
		end

		def self.respond_to?(method_sym, include_private = false)
			if method_sym.to_s =~ /^(.*)_stats$/
				true
			elsif method_sym.to_s =~ /^(.*)_stat$/
				true
			else
				super
			end
		end

		protected

		def handle_stat(action, stat)
			raise LemonStats::Error "Invalid action #{action} request in stats store #{type}." if !VALID_ACTIONS.include?(action.to_s)

			method_name = "#{action}_stat"
			success = false

			stat.mutex.synchronize do
				if respond_to? method_name
					success = send(method_name, stat)
				else
					raise  LemonStats::Error, "#{action} method for stat of type #{stat.type} not found for store type: #{@type}"
				end

				stat.saved! if success
			end

			success
		end

		def handle_stats(action, stats)
			raise LemonStats::Error "Invalid action #{action} request in stats store #{type}." if !VALID_ACTIONS.include?(action.to_s)

			stats.each do |stat|
				handle_stat action, stat
			end
		end

	end
end