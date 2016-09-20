class LemonStats
	class TimerStat < LemonStats::BaseStat
		
		def initialize(name, group, val = 0, &block)
			super(name, group, :timer, val, &block)
		end

		def update(val = nil)
			self.set_value(val) do |current_val|
				current_val + val
			end
		end

		def clear
			self.set_value(0)
		end

		alias_method :increment, :update

	end
end