= power

* 

== DESCRIPTION:

This is going to be a web base site to save power panel information
for a facility

== FEATURES/PROBLEMS:


== SYNOPSIS:
   require 'power-panel'
    ogd = Power::Panel.new(42)
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

    panel = Power::Panel.load_yaml(ogd.to_yaml)

    expect(panel.to_yaml).to eq( ogd.to_yaml)

== REQUIREMENTS:



== INSTALL:

* sudo gem install power

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

(The MIT License)

Copyright (c) 2013 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
