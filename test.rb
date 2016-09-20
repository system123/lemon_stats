require_relative './lib/lemon_stats'

stats = LemonStats.new "stats"

stats.add_store LemonStats::LogStore.new "main", {:file_path => "./test.txt"}

stats.add_stat LemonStats::GaugeStat.new "total", "agents"
stats.add_stat LemonStats::TimerStat.new "tt", "agents:1000"
stats.add_stat LemonStats::CounterStat.new "calls", "agents:1000"
stats.add_stat LemonStats::TimerStat.new "tt", "agents:2000"
stats.add_stat LemonStats::CounterStat.new "calls", "agents:2000"

# stats.update_stat "tt", "agents:1000", 1

tt1000 = stats.get_stat "tt", "agents:1000"

# puts "value = #{tt1000.value}"

# tt1000.update 3
# stats.save_dirty_stats

puts "value = #{tt1000.value}"

th = []


	th << Thread.new {
		(1..500).each { |i|
			tt1000.update 1
			stats.save_dirty_stats
		}
	}

	th << Thread.new {
		(1..500).each { |i|
			stats.update_stat "tt", "agents:1000", -1
		}
	}


th.each{|t| t.join}

puts "value = #{tt1000.value}"


