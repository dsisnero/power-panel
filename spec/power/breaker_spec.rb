require File.join(File.dirname(__FILE__), '../spec_helper')


module Power

  describe Breaker do

    context 'an initialized breaker' do

      let(:slot1){ Slot.new(1)}
      let(:slot2){ Slot.new(2)}
      let(:slot3){Slote.new(3)}
      let(:breaker){ Breaker.new(:amps =>20, :description => 'service')}
      subject{ breaker.connect(slot1); breaker}

      it 'has the correct number' do
        expect( subject.number).to eq(1)
      end

      it '#to_array' do
        expect( subject.to_array).to eq( [1,'service',20])
      end

      it '#to_hash' do
        expect( subject.breaker_hash).to eq({"brk_1_amps" => 20,
                                              "brk_1_service" => 'service'})
      end

      it{ should_not be_doubled}

      it 'should be removed' do
        subject.remove
        slot1.breaker.should be_nil
      end

      it 'can be retrieved from slot' do
        expect( subject.slot.breaker).to equal(subject)
      end


    end
  end


  describe DoubleBreaker do
    context 'an initialized breaker' do

      let(:slot1){ Slot.new(1)}
      let(:slot2){ Slot.new(2)}
      let(:slot3){Slote.new(3)}
      let(:breaker){ DoubleBreaker.new( amps: 20,
                                        description: 'Service1')
      }
      subject{ breaker.connect(slot1,slot2); breaker}


      it 'has the correct number' do

        expect( subject.number).to eq( [1,2])
      end

      it '#to_array ' do
        expect(subject.to_array).to eq( [[1,2], 'Service1',20])
      end

      it '#breaker_hash' do
        expect(subject.breaker_hash).to eq( { "brk_1_amps"=>20,
                                              "brk_1_service"=>'Service1',
                                              "brk_2_amps"=>20,
                                              "brk_2_service"=>'Service1'})
      end


      it{ should be_doubled}



    end
  end





  describe Slot do

    context 'just initialized' do
      let(:number){3}
      subject{ Slot.new(number)}

      it 'is not connected' do
        expect( subject).to_not be_connected
      end

      it '#to_s' do
        expect( subject.to_s).to eq( "#{number}: ")
      end




    end


  end

end
