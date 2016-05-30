require "lemon_stats/version"

%w(
  stores
  types
  stats_group
).each { |f| require "lemon_stats/#{f}" }

class LemonStats
  	attr_accessor :store_collection
	attr_accessor :stats_group
	attr_accessor :base_key

	def intialize(base_endpoint)
		@base_key = base_endpoint
		@store_collection = LemonStats::StoreCollection.new @base_key
		@stats_group = LemonStats::StatsGroup.new @base_key, @store_collection
	end

	def add_store(store)
		@store_collection.add store
	end

	def remove_store(store)
		@store_collection.remove store
	end

	def add_stats_group(group)
		@stats_group.add_sub_group group
	end

	def remove_stats_group(group)
		@stats_group.remove_sub_group group
	end

	def find_group_by_name(group)

	end

	def add_stat(stat, key)

	end

	def remove_stat(stat, key)

	end
end
