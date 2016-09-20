class LemonStats
	class StoreCollection
	    # include Celluloid

		attr_accessor :stats_stores
		attr_accessor :base_store_key
		attr_accessor :mutex

		def initialize(base_key)
			@stats_stores = {}
			@base_store_key = base_key
			@mutex = Mutex.new
		end

		def add(store)
			store.set_key @base_store_key
			@mutex.synchronize do
				@stats_stores[store.id] = store
			end
		end

		def remove(store)
			@mutex.synchronize do
				@stats_stores.delete store.id
			end
		end

		def find_by_id(id)
			@mutex.synchronize do
				@stats_stores[id]
			end
		end

		def length
			@stats_stores.length
		end

		def save_stats(stats=[])
			@mutex.synchronize do
				@stats_stores.each do |id, store|
					store.save_stats stats
				end
			end
		end

		def remove_stats(stats=[])
			@mutex.synchronize do
				@stats_stores.each do |id, store|
					store.remove_stats stats
				end
			end
		end

		def load_stats(key)
			raise LemonStats::Error, "No default stats store is specified" if @default_store.nil?
			stats = @default_store.load_stats key
		end

		def clear_stats(key)
			raise LemonStats::Error, "No default stats store is specified" if @default_store.nil?
			stats = @default_store.clear_stats key
		end

	end
end