require 'thread'

class LemonStats
	class BaseStat
		attr_accessor :group			# A key for the group this stat belongs to
		attr_accessor :name				# A name for this stat
		attr_accessor :type 			# The type of this stat
		attr_accessor :value 			# Current value of this stat
		attr_accessor :delta			# Difference between stat values after update
		attr_accessor :dirty			# Has this stat been updated
		attr_accessor :aggregator 		# Proc/Block for aggregating bound stats when one is updated
		attr_reader   :linked_stats		# Are updated whenever the owning stat is updated
		attr_reader   :bound_stats		# These are the stats which this stat is linked to, easier access for calculating derived stats
		attr_reader   :mutex			# Mutex to prevent race conditions

		def initialize(name, group, type, init_value, &block)
			@name = name.to_sym
			self.group = group
			@type = type
			@value = init_value
			@dirty = true
			@delta = 0
			@aggregator = block
			@linked_stats = []
			@bound_stats = []
			@mutex = Mutex.new
		end

		def update(value)
			@mutex.synchronize do
				dv = value - @value 
				@delta = @dirty ? (dv + @delta) : dv
				@value = value
				@dirty = true

				@linked_stats.each do |stat|
					stat.updated_bound_stat self
				end
			end
			
			self
		end

		def aggregator=(&block)
			aggregator = block
		end

		def group=(gid)
			valid_group? gid
			@group = gid
		end

		def name=(name)
			@name = name.to_sym
		end

		def clear
			raise  LemonStats::Error, "Clear function not declared for Stat type #{@type}"
		end

		def saved!
			@dirty = false
		end

		def set_value(value)
			update(value)
		end

		def link(stat)
			raise LemonStats::Error, "Cyclic reference between stats #{@name} and #{stat.name}" if @bound_stats.include? stat
 			
 			@mutex.synchronize do
				@linked_stats << stat
			end

			stat.bind self
			stat.updated_bound_stat self 
			stat
		end

		def unlink(stat)
			@mutex.synchronize do
				unlinked_stat = @linked_stats.delete stat
			end

			if unlinked_stat
				unlinked_stat.unbind self 
				unlinked_stat.updated_bound_stat self
			end

			unlinked_stat
		end

		protected

		def valid_group?(group)
			valid = (group =~ /^[a-z0-9_:\-]+$/) ? true : false
			raise LemonStats::GroupError, "Group name '#{group}' is invalid." unless valid
			valid
		end

		def bind(stat)
			@mutex.synchronize do
				@bound_stats << stat
			end
		end

		def unbind(stat)
			@mutex.synchronize do
				@bound_stats.delete stat
			end
		end

		def updated_bound_stat(stat)
			val = stat.value #Default tot taking the value of the stat which changed

			if @aggregator
				val = @aggregator.call( stat, @bound_stats )
			end

			update val
		end
	end
end