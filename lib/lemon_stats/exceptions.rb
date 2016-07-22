class LemonStats
	class Error < StandardError; end
	class GroupError < LemonStats::Error; end
	class NotFoundError < LemonStats::Error; end
end