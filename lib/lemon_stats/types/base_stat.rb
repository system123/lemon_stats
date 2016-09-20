require 'thread'

class LemonStats
	class BaseStat
		attr_accessor :group			# A key for the group this stat belongs to
		attr_accessor :name				# A name for this stat
		attr_accessor :type 			# The type of this stat
		attr_accessor :value 			# Current value of this stat
		attr_accessor :delta			# Difference between stat values after update
		attr_accessor :dirty			# Has this stat been updated
		# attr_accessor :aggregator 		# Proc/Block for aggregating bound stats when one is updated
		# attr_reader   :linked_stats		# Are updated whenever the owning stat is updated
		# attr_reader   :bound_stats		# These are the stats which this stat is linked to, easier access for calculating derived stats
		attr_reader   :mutex			# Mutex to prevent race conditions

		def initialize(name, group, type, init_value)
			@name = name.to_sym
			@group = group if valid_group? group
			@type = type
			@value = init_value
			# @aggregator = block

			@dirty = true
			@delta = 0
			# @linked_stats = []
			# @bound_stats = []			
			@mutex = Mutex.new
		end

		# def aggregator=(&block)
		# 	aggregator = block
		# end

		def value
			@mutex.synchronize{ @value }
		end

		def clear
			raise  LemonStats::Error, "Clear function not declared for Stat type #{@type}"
		end

		def update(value = nil)
			raise  LemonStats::Error, "Update function not declared for Stat type #{@type}"
		end

		def saved!
			@mutex.synchronize{ @dirty = false }
		end

		# def link(stat)
		# 	raise LemonStats::Error, "Cyclic reference between stats #{@name} and #{stat.name}" if @bound_stats.include? stat
 			
 	# 		@mutex.synchronize do
		# 		@linked_stats << stat
		# 	end

		# 	stat.bind self
		# 	stat.updated_bound_stat self 
		# 	stat
		# end

		# def unlink(stat)
		# 	@mutex.synchronize do
		# 		unlinked_stat = @linked_stats.delete stat
		# 	end

		# 	if unlinked_stat
		# 		unlinked_stat.unbind self 
		# 		unlinked_stat.updated_bound_stat self
		# 	end

		# 	unlinked_stat
		# end

		def to_s
			"Stat [#{@group}:#{@name}] has value of #{@value} and is dirty:#{@dirty}"
		end

		# def bind(stat)
		# 	@mutex.synchronize do
		# 		@bound_stats << stat
		# 	end
		# end

		# def unbind(stat)
		# 	@mutex.synchronize do
		# 		@bound_stats.delete stat
		# 	end
		# end

		# def updated_bound_stat(stat)
		# 	val = stat.value #Default to take the value of the stat which changed

		# 	if @aggregator
		# 		val = @aggregator.call( stat, @bound_stats )
		# 	end

		# 	set_value val
		# end

		private

		def valid_group?(group)
			valid = (group =~ /^[a-z0-9_:\-]+$/) ? true : false
			raise LemonStats::GroupError, "Group name '#{group}' is invalid." unless valid
			valid
		end

		def set_value(new_value)
			@mutex.synchronize do
				dv = new_value - @value 
				@delta = @dirty ? (dv + @delta) : dv

				if block_given?
					@value = yield @value
				else
					@value = new_value
				end

				@dirty = true

				# @linked_stats.each do |stat|
				# 	stat.updated_bound_stat self
				# end

				@value
			end
		end

	end
end