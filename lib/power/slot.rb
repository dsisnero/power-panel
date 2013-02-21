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
    end

    def remove
      @breaker = nil
    end

    def breaker_hash
      return {} unless connected?
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

    def inspect
      "#{self.class}: #{number}"
    end

    def to_s
      "#{number}: #{breaker}"
    end

    def to_array
      breaker.to_array
    end

    def description
      breaker.description if connected?
    end

    def amps
      breaker.amps if connected?
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

    def connected_slot?(n)
      self[n].connected?
    end


    def can_connect?(*nums)
      nums.all?{|n| ! connected_slot?(n)}
    end

    def size2_array?(numbers)
      (numbers.kind_of? Array) && numbers.size == 2
    end

    def add_double_breaker(numbers,desc,amps)
      unless size2_array?(numbers)
         raise ArgumentError
      end

      n1, n2 = numbers.sort
      unless can_connect?(n1,n2)
        raise AlreadyConnected
      end

      breaker = DoubleBreaker.new(:description => desc, :amps => amps)
      breaker.connect(get_slot(n1),get_slot(n2))
    end

    def add_single_breaker(number,desc,amps)
      raise AlreadyConnected unless can_connect?(number)
      breaker = Breaker.new(:description => desc, :amps => amps)
      breaker.connect(get_slot(number))
    end

    def remove(num)
      self[num].remove
    end

    def [](num)
      raise IndexError if num < 0 or num > (size - 1)
      @slots[num-1]
    end

    def get_slot(num)
      self[num]
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
      {:services => connected_services}
    end

    def connected
      slots.select{|b| b.connected?}
    end

    def connected_breakers
      connected.map{|b| b.breaker}.uniq
    end

    def connected_services
      connected_breakers.map{|b| b.to_array}
    end



  end

end
