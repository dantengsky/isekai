require "./bit_manip"

@[AlwaysInline]
private def max_bits_in_sum (n : Int32, m : Int32) : Int32
    return n if m == 0
    return m if n == 0
    return Isekai::AltBackend::BitManip.max(n, m) + 1
end

@[AlwaysInline]
private def max_bits_in_product (n : Int32, m : Int32) : Int32
    return n * m if n <= 1 || m <= 1
    return n + m
end

module Isekai::AltBackend

private struct DynamicRange
    include Comparable(DynamicRange)

    private UNDEFINED = -1

    @[AlwaysInline]
    def initialize (@width : Int32)
    end

    @[AlwaysInline]
    def self.new_for_const (value : UInt128)
        return self.new(width: BitManip.nbits(value))
    end

    @[AlwaysInline]
    def self.new_for_undefined
        return self.new(width: UNDEFINED)
    end

    @[AlwaysInline]
    def self.new_for_bitwidth (bitwidth : BitWidth)
        return self.new(width: bitwidth.@width)
    end

    @[AlwaysInline]
    def self.new_for_width (width : Int32)
        return self.new(width: width)
    end

    @[AlwaysInline]
    def self.new_for_bool
        return self.new(width: 1)
    end

    @[AlwaysInline]
    def undefined?
        @width == UNDEFINED
    end

    def + (other : DynamicRange)
        return DynamicRange.new_for_undefined if undefined? || other.undefined?
        return DynamicRange.new(max_bits_in_sum(@width, other.@width))
    end

    def + (c : UInt128)
        return self if undefined?
        c_nbits = BitManip.nbits(c)
        result = max_bits_in_sum(@width, c_nbits)
        if result <= 128
            max_value = (1_u128 << @width) - 1
            result = BitManip.nbits(c + max_value)
        end
        return DynamicRange.new(result)
    end

    def * (other : DynamicRange)
        return DynamicRange.new_for_undefined if undefined? || other.undefined?
        return DynamicRange.new(max_bits_in_product(@width, other.@width))
    end

    def * (c : UInt128)
        return self if undefined?
        c_nbits = BitManip.nbits(c)
        result = max_bits_in_product(@width, c_nbits)
        if result <= 128
            max_value = (1_u128 << @width) - 1
            result = BitManip.nbits(c * max_value)
        end
        return DynamicRange.new(result)
    end

    def <=> (other : DynamicRange)
        return nil if undefined? || other.undefined?
        @width <=> other.@width
    end

    @[AlwaysInline]
    def max_nbits : Int32?
        @width unless undefined?
    end
end

end
