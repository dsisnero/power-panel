require File.join(File.dirname(__FILE__), 'breaker')
require File.join(File.dirname(__FILE__), 'slot')
require 'virtus'
require 'hash_maps'
require 'yaml'
require 'json'

module Power

  class AlreadyConnectd < StandardError ;  end


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

    def is_single_breaker_number(number)
      number.kind_of? Integer
    end

    def add_breaker(number,description,amps = nil)
      amps = amps || default_amps
      if is_single_breaker_number(number)
        slots.add_single_breaker(number,description,amps)
      else
        slots.add_double_breaker(number,description,amps)
      end

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

    def get_slot(number)
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

