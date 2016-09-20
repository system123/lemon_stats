class LemonStats
	class GaugeStat < LemonStats::BaseStat
		
		def initialize(name, group, val = 0, &block)
			super(name, group, :gauge, val, &block)
		end

		def update(val = nil)
			self.set_value val
		end

		def clear
			self.set_value(0)
		end

	end
end