# QuasarProject_AgilentE3648A
OPCUA server based on Quasar to control a power supply Agilent E3648A and a WinCC OA project acting as client to control it.

The linux-GPIB package (https://linux-gpib.sourceforge.io/) is required for the GpibPowerSupply module.

This project was built on a CC7 machine.

Following versions are used:
- Quasar [v1.3.11](https://github.com/quasar-team/quasar/tree/v1.3.11)
- open62541-compat [version 1.2.0](https://github.com/quasar-team/open62541-compat/tree/fe9fb793f44563503f0e930f8e75d9dc38dee233)
- Cacophony [version December 2019](https://github.com/quasar-team/Cacophony/tree/2c745d9793779538c83ee10f22a089ad92e8167f)

### Installing the server
This server uses open62541 (https://open62541.org/) and open62541-compat (https://github.com/quasar-team/open62541-compat). The instructions for their installation are available in the given links.
In addition the same requirements of the Quasar server listed [here](https://github.com/quasar-team/quasar/blob/master/Documentation/quasar.html) are necessary.

To install this server, first clone this repo. Then set quasar in order to use open62541 and open62541-compat:
```
cd QuasarProject_AgilentE3648A/
./quasar.py enable_module open62541-compat v1.2.0
./quasar.py set_build_config open62541_config.cmake
./quasar.py build
```
The configuration of the server is in file `build/bin/config.xml`, any change according to a specific setup can be applied there (e.g. number of power supplies to be controlled, the GPIB address of the device to be controlled).

Make sure that the GPIB address is correct for your setup: `board` and `primaryAddress` are compulsory values. `secondaryAddress`, `timeOut`, `send_eoi` and `eos` can also be specified, otherwhise they will be set to default.

Now run the server:
```
cd build/bin/
./OpcUaServer
```

A message like
```
TCP network layer listening on opc.tcp://control-6.pixel.ge.infn.it:4841/
```
will show the server address.

### Installing the WinCC OA package
Before installing the fwLabSetup component into a WinCC OA project edit file `winccoa/fwLabSetup/dplist/fwLabSetup/fwLabSetupOpcua.dpl `: at line 17 replace `opc.tcp://control-6.pixel.ge.infn.it:4841/` with your server address.

<!--
In order to import the necessary DPTs and DPs to  a WinCC OA project, add Cacophony to your server project. In the server main directory, run
```
git clone https://github.com/quasar-team/Cacophony.git 
```
then produce the scripts for WinCC OA with:
-->
In order to import the necessary DPTs and DPs to  a WinCC OA project, use Cacophony to produce the scripts for WinCC OA:
```
python Cacophony/generateStuff.py --dpt_prefix Gpib_ --server_name OPCUA_LABSETUP --driver_number 10 --subscription OPCUA_LABSETUP_DefaultSubscription
```

Once you have WinCC OA 3.16 installed and you have created the project, copy the scripts into it:
```
cp Cacophony/generated/*ctl <winccoa-project-path>/scripts/libs/
```

Now make sure that the JCOP Installation Tool is installed in your WinCC OA project (available [here](https://jcop.web.cern.ch/jcop-framework-component-installation-tool)). Use the installation tool to install the following JCOP components of the framework (full framework available [here](https://jcop.web.cern.ch/jcop-framework-0)):
- fwCore
- fwXML
- fwTrending

Restart the project when asked.

Now you can install the fwLabSetup component (located in this repository under `winccoa/fwLabSetup/`) in the same way using the JCOP installation tool.

Open panel `/panels/fwLabSetup/fwLabSetupCacophony.pnl` and edit the "clicked" script of button `2) Create DPs` to replace `<path-to-quasar-project>` with your quasar server main directory. Then run the panel and click on the buttons in the suggested order: first  button `1)`, then button `2)` to run the scripts to create DPTs and DPs with the correct addresses.  When pressing button `2)` the Quasar server must be running.

The main panel (a reference panel) to control and monitor the GPIB power supply is `panels/fwLabSetup/fwLabSetupChannelOperation.pnl`. In order to use it, you must set the dollar parameter `$sDpName` to a channel DP (that is of DP type `Gpib_Channel`), e.g. `dist_1:ps1/channel1`.
A possible way to use this panel is to create a new empty panel and drag-and-drop this panel there.

### Requirements: summary
- linux GPIB (https://linux-gpib.sourceforge.io/)
- open62541 (https://open62541.org/)
- open62541-compat (https://github.com/quasar-team/open62541-compat)
- quasar requirements (https://github.com/quasar-team/quasar/blob/master/Documentation/quasar.html)
- WinCC OA 3.16 with JCOP Installation Tool
- JCOP components `fwCore`, `fwXML`, `fwTrending`

