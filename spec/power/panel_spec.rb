require File.join(File.dirname(__FILE__), '../spec_helper')


module Power

  describe Panel do


    context 'a panel initialized with 42 slots' do

      subject{ Panel.new(42)}

      it 'should have correct size' do
        expect( subject.size).to eq(42)
      end

      describe 'adding a single circuit' do
        it 'should have a slot' do
          subject << [1, 'service', 30]
          slot = subject.get_slot(1)
          slot.to_array.should == [1,'service',30]
        end

      end

      describe 'adding a double circuit' do
        it 'should add correctly' do
          subject << [[1,3], 'service', 30]
          slot = subject.get_slot(1)
          slot.to_array.should == [[1,3],'service', 30]
        end

      end

      describe 'add even' do
        context 'with range' do

          it 'should add correctly' do
            subject.add_even(2..6, 'spare')
            subject.connected_slots.map{|s| s.number}.should include(2,4,6)
          end
        end
      end



    end


    it 'correctly serializes' do
      ogd = Panel.new(42)
      ogd.manufacturer = 'Square D'
      ogd.model = 'MHC35SHR'
      ogd.phase = 1
      ogd.wires = 3
      ogd.volts = '120/240'
      ogd.main_breaker_amps = 100
      ogd.add_breakers [
                        [1,'Spare'],
                        [3,'Outside Light'],
                        [5,'Appliance Rack'],
                        [7,'LPG Alaram & Blower'],
                        [9, 'West Wall Outlet'],
                        [[11,13], 'EG Room Heater', 30],
                        [[15,17], 'HVAC #1', 30],
                        [[19,21], 'HVAC #2', 30],
                        [23, 'Equip Room Light'],
                        [25, 'Spare'],
                        [27,'Outside GFCI'],
                        [29, 'North Wall Outlet'],
                        [31, 'Spare'],
                        [[35,37], 'TVSS', 30],
                        [[39,41], 'Main', 100],
                       ]
      ogd.add_breakers( [
                         [[2,4], '24V Charger- RCL',30],
                         [6, 'South Wall Outlet'],
                         [8, 'Computer Outlet'],
                         [10, 'E/G Room Outlet'],
                         [12, 'E/G Room Lights'],
                         [14, 'Spare'],
                        ])

      ogd.add_even( 16..22, 'Spare')
      ogd.add_breakers( [
                         [[24,26], 'Spare', 30],
                         [28, 'Spare'],
                         [30,'Hydrogen Fuel Cell'],
                         [32,'Security Alarm']
                        ])

      panel = Panel.load_yaml(ogd.to_yaml)
      sb = panel.get_slot(28)
      db = panel.get_slot(24)
      expect(panel.to_yaml).to eq( ogd.to_yaml)
    end

  end

end
