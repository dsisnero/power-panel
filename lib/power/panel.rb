require 'virtus'
require 'hash_maps'
require 'yaml'
require 'json'


module Power

  class Slot

    attr_reader :breaker, :number

    def initialize(number)
      @number = number
    end

    def connected?
      !!@breaker
    end

    def connect(breaker)
      @breaker = breaker
      breaker.slots << self
    end

    def remove
      slots = breaker.remove_slots
      slots.each do |s|
        s.remove_breaker
      end

    end

    def breaker_hash
      { "brk_#{number}_amps" => amps,
        "brk_#{number}_service" => description
      }
    end

    def remove_breaker
      @breaker = nil
    end


    def doubled?
      connected? && breaker.doubled?
    end

    def to_s
      "#{number}: #{breaker}"
    end

    def breaker_array
      breaker.to_array
    end

    def description
      breaker.description if connected?
    end

    def amps
      breaker.amps if connected?
    end

  end

  class Breaker

    include Virtus

    attribute :slots, Array[Slot]
    attribute :description, String
    attribute :amps, Integer, :default => 20

    def breaker_hash
      { "brk_#{number}_amps" => amps,
        "brk_#{number}_service" => description
      }
    end

    def numbers
      doubled? ? slots.map{|s| s.number} : slots.first.number
    end

    def to_s
      "[#{numbers}, #{description}, #{amps}]"
    end

    def to_array
      [ numbers, description,amps]
    end


    def remove_slots
      dup = slots.dup
      slots = []
      dup
    end

    def doubled?
      slots.size > 1
    end

  end

  class Slots

    attr_reader :slots, :size

    def add_from_array(array)
      array.each do |a|
        numbers,desc,service = a
        add_breaker(numbers,desc,service)
      end
    end

    def initialize(size)
      @size = size
      @slots = []
      size.times do |i|
        @slots[i] = Slot.new(i + 1)
      end
    end

    def each_odd
      connected.select{|b| b.number.odd?}.each do |b|
        yield b
      end

    end

    def each_even
      connected.select{|b| b.number.even?}.each do |b|
        yield b
      end

    end

    def add_breaker(number, desc,amps)
      breaker = Breaker.new(:description => desc, :amps => amps)
      numbers = Array(number)
      numbers.each do |num|
        connect_breaker_to_slot(num,breaker)
      end
    end

    def remove(num)
      self[num].remove
    end

    def [](num)
      raise IndexError if num < 0 or num > (size - 1)
      @slots[num-1]
    end

    def connect_breaker_to_slot(number, breaker)
      slot = self[number]
      slot.connect(breaker)
    end

    def to_title_hash
      connected.reduce({}) do |result,slot|
        result.merge(slot.breaker_hash)
      end
    end


    def to_hash
      services = connected.reduce([]) do |result,slot|
        result +   [slot.breaker_array]
      end
      {:services => services}
    end

    def connected
      slots.select{|b| b.connected?}
    end

  end

  module PanelAtts

    include Virtus

    attribute :size, Integer
    attribute :manufacturer, String
    attribute :model, String
    attribute :breaker_type, String
    attribute :series, String
    attribute :phase, String
    attribute :wires, String
    attribute :volts, String
    attribute :amps, Integer
    attribute :main_breaker_amps, Integer

  end

  class Panel

    attr_reader :slots, :default_amps

    def self.load_yaml(yaml)
      h = YAML::load yaml
      panel = new(h[:size])
      panel.attributes = h
      panel.add_breakers( h[:services])
      panel
    end

    def initialize(size,opts={})
      @slots = Slots.new(size)
      @default_amps = opts.fetch(:default_amps, 20)
      self.extend PanelAtts
      self.size = size
    end

    def add_breaker(number,description,amps = nil)
      amps = amps || default_amps
      slots.add_breaker(number,description,amps)
    end

    def add(*args)
      number,desc,amps = ensure_array(args)
      add_breaker(number,desc,amps)
    end

    def add_breakers(array_of_array)
      array_of_array.each do |b|
        add *b
      end
    end

    def <<(*args)
      add(*args)
    end

    def remove(num)
      slots.remove(num)
    end

    def serialize_hash
      attributes.merge( slots.to_hash )
    end

    def to_yaml
      serialize_hash.to_yaml
    end

    def to_json
      serialize_hash.to_json
    end

    def title_blocks_hash
      attributes.merge( slots.to_title_hash).select{|k,v| !v.nil?}.map_kv{|k,v| [k.to_s,v.to_s.upcase] }
    end

    def add_same(*nums,desc)

      nums.each do |num|
        add(num,desc)
      end
    end

    def add_even(*nums,desc)
      nums = ensure_array(nums)
      nums.select{|n| n.even?}.each do |num|
        add(num,desc)
      end
    end

    def add_odd(*nums,desc)
      nums = ensure_array(nums)
      nums.select{|n| ! n.even?}.each do |num|
        add(num,desc)
      end
    end

    def each_even(&block)
      slots.each_even(&block)
    end

    def each_odd(&block)
      slots.each_odd(&block)
    end

    def breaker(number)
      slots[number]
    end

    protected

    def ensure_array(nums)
      case nums.first
      when Array
        nums.first
      when Range
        nums.first.to_a
      else
        nums
      end
    end


  end

end

