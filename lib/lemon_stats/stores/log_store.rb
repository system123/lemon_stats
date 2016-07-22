class LemonStats
	class LogStore < LemonStats::StatsStore
		attr_accessor :log_file
		attr_reader :mutex

		def initialize(id, config = {})
			super(id, :log_store, config)
			@mutex = Mutex.new

			raise LemonStats::Error, "No file has been specified for the Log Store." if config[:file_path].nil?
		end

		def save_stat(stat)
			check_file_open
			write_file fmt_log(stat, "#{stat.value}")
		end

		def remove_stat(stat)
			check_file_open
			write_file fmt_log(stat, "Removed")
		end

		def clear_stat(stat)
			check_file_open
			write_file fmt_log(stat, "#{stat.value} Cleared")
		end

		def close
			@log_file.close
		end

		private

		def fmt_log(stat, msg)
			"[#{Time.now}] - #{stat.name} <#{stat.type}>: #{msg}"
		end

		def write_file(msg)
			@mutex.synchronize {
				check_file_open?
				@log_file.puts msg
			}
		end

		def check_file_open?
			if @log_file.nil? || @log_file.closed?
				@log_file = File.open(@config[:file_path], 'a+')
			end

			raise LemonStats::Error "Could not open the stats log store file #{@config.inspect}" if @log_file.closed?
		end

	end
end