require "time"
require "securerandom"
require "baseconv"
require "snowflakey/version"

class Snowflakey
  BASE = 36

  def initialize(prefix, size, time, id, base)
    @prefix = prefix
    @size   = size
    @time   = time
    @id     = id
    @base   = base.to_i
  end

  attr_reader :prefix, :size, :time, :id, :base

  class << self
    def generate(prefix = nil, size: 96, time: Time.now, base: BASE)
      r = (SecureRandom.random_number * 1e16).round

      new(prefix, size, time.utc, r, base).to_s
    end

    def verify(snowflake, size: 96, base: BASE)
      id, prefix = snowflake.reverse.split("_", 2).map { |s| s.reverse }
      ms         = id.to_i(base) >> (size - 41)
      time       = Time.at((ms / 1e3)).utc
      id         = Baseconv.convert(id, from_base: base.to_i, to_base: 10)
      id         = id.to_i % (2 ** (size - 41))

      new(prefix, size, time, id, base)
    end
  end

  def to_s
    t  = (@time.to_f * 1e3).round
    id = t << (@size - 41)
    id = id | @id % (2 ** (@size - 41))
    id = Baseconv.convert(id, from_base: 10, to_base: @base)

    [*@prefix, id].compact.join("_")
  end

  def inspect
    to_s
  end
end