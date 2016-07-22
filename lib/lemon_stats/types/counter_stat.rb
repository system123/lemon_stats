class  LemonStats
	class CounterStat < LemonStats::BaseStat
		
		def initialize(name, group, val = 0, &block)
			super(name, group, :counter, val, &block)
		end

		def update(val = nil)
			super(@value + val)
		end

		def clear
			@value = 0
		end

		alias_method :increment, :update

	end
end