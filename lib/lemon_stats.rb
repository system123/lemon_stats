require "lemon_stats/version"

%w(
  stores
  types
  stats_collection
  exceptions
).each { |f| require "lemon_stats/#{f}" }

class LemonStats

  	attr_accessor :store_collection
  	attr_accessor :stats_collection
	attr_accessor :base_group
	attr_accessor :base_key
	attr_reader   :mutex

	def initialize(base_endpoint)
		@base_key = base_endpoint
		@stats_collection = LemonStats::StatsCollection.new
		@store_collection = LemonStats::StoreCollection.new @base_key
	end

	def add_store(store)
		@store_collection.add store
	end

	def find_store(id)
		@store_collection.find_by_id id
	end

	def remove_store(store)
		@store_collection.remove store
	end

	def add_stat(stat)
		@stats_collection << stat
		save_dirty_stats
	end

	def stats?
		@stats_collection.length
	end

	def stats
		@stats_collection.clone[nil]
	end

	def get_stat(name, group=nil)
		@stats_collection.get name, group
	end

	def remove_stat(stat)
		@stats_collection.remove stat
	end

	def get_stats_group(group)
		@stats_collection[group]
	end

	def update_stat(name, group, value)
		stat = @stats_collection.get name, group
		stat.update value
		save_dirty_stats
	end

	def update_stats(gid, &block)
		group = @stats_collection.get_group_as_collection gid
		group.instance_eval &block
		save_dirty_stats
	end

	def update_stat_at(key, value)
		name, gid = key_to_name_group key
		update_stat name, gid, value
	end

	def save_dirty_stats
		@store_collection.save_stats @stats_collection.get_dirty
	end

	private

	def key_to_name_group(key)
		parts = key.rpartition(':')
		return parts.last, parts.first
	end

end
