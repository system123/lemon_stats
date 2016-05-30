require "lemon_stats/version"

%w(
  stores
  types
  stats_group
).each { |f| require "lemon_stats/#{f}" }

class LemonStats
  # Your code goes here...
end
