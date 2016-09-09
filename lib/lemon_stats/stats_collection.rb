class LemonStats
#TODO Add locking and thread safety
	class StatsCollection
		attr_accessor :stats
		attr_reader :mutex

		def initialize(stats_init = {})
			@stats = stats_init
			@mutex = Mutex.new
		end

		def <<(stat)
			add(stat)
		end

		def [](gid)
			get_group gid
		end

		def []=(gid, stats)
			@stats[gid] = stats
		end

		def add(stat)
			@stats[stat.group] = [] unless has_group? stat.group

			@mutex.synchronize do
				@stats[stat.group] << stat
			end
		end

		def remove(stat)
			group = get_group stat.group
			
			@mutex.synchronize do
				group.values.delete stat if group
			end
		end

		def remove!(stat)
			removed_stat = remove stat
			raise LemonStats::NotFoundError, "Stat '#{stat.name}' in group '#{stat.group}'." unless removed_stat
			removed_stat
		end

		def remove_by_name!(name, group)
			remove get!(name, group)
		end

		def get(name, gid=nil, all=false)
			search_groups = get_group gid
			stat = search_groups.select { |v| v.name == name.to_sym } if search_groups
			stat = stat.first unless all
			stat
		end

		def get!(name, gid=nil)
			stat = get name, gid
			raise LemonStats::NotFoundError, "Stat '#{stat.name}' not found." unless stat
			stat
		end

		def get_group(gid)
			if gid.is_a?(Regexp)
				get_group_by_pattern gid
			else
				get_group_by_name gid
			end
		end

		def get_group!(gid)
			raise LemonStats::NotFoundError, "Stat group '#{group}' was not found." unless has_group?(gid)
			get_group gid
		end

		def remove_group(gid)
			@stats.delete gid
		end

		def remove_group!(gid)
			raise LemonStats::NotFoundError, "Stat group '#{group}' could not be removed." unless has_group?(gid)
			remove_group gid
		end

		def get_dirty(gid = nil)
			group = get_group gid
			group.values.flatten.select { |v| v.dirty == true }
		end

		def has_group?(gid)
			if gid.is_a?(Regexp)
				!!@stats.keys.detect { |key| key =~ gid }
			else
				@stats.has_key? gid
			end
		end

		def update(name, val)
			get!(name).update val
		end

		def get_group_as_collection(gid)
			StatsCollection.new get_group(gid)
		end

		private

		def get_group_by_name(gid)
			if gid
				@stats[gid]
			else
				@stats.values.flatten
			end
		end

		def get_group_by_pattern(gid_regex)
			@stats.select{ |k,v| k =~ gid_regex }
		end


	end

end
