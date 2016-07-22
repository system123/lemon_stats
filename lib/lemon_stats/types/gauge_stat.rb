class LemonStats
	class GaugeStat < LemonStats::BaseStat
		
		def initialize(name, group, val = 0, &block)
			super(name, group, :gauge, val, &block)
		end

		def update(val = nil)
			super(val)
		end

		def clear
			@value = 0
		end

	end
end