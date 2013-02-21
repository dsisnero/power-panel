require 'virtus'
require File.join(File.dirname(__FILE__), 'slot')

module Power

  class ABreaker

    include Virtus

    attribute :description, String
    attribute :amps, Integer, :default => 20

    def initialize(*args)
      super(*args)
    end

    def to_array
      [ number, description,amps]
    end

  end

  class Breaker  < ABreaker

    include Virtus

    attribute :slot, Slot


    def breaker_hash
      { "brk_#{number}_amps" => amps,
        "brk_#{number}_service" => description
      }
    end

    def connect(slot)
      slot.connect(self)
      self[:slot] = slot
    end

    def slots
      [slot]
    end

    def number
      slot.number
    end

    def to_s
      "[#{number}, #{description}, #{amps}]"
    end

    def remove
      slot.remove_breaker
    end

    def doubled?
      false
    end


  end


  class DoubleBreaker < ABreaker

    attribute :slot1, Slot
    attribute :slot2, Slot

    def number
      [slot1.number, slot2.number]
    end

    def breaker_hash
      slot1.breaker_hash.merge( slot2.breaker_hash)
    end

    def connect(s1,s2)
      sorted_s1,sorted_s2 = [s1,s2].sort_by{|s| s.number}
      sorted_s1.connect(self)
      sorted_s2.connect(self)
      self[:slot1] = sorted_s1
      self[:slot2] = sorted_s2

    end

    def doubled?
      true
    end


  end


end
