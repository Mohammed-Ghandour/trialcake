Before Start:
=============

PLease run one of the "env$$$.sh" based on the "CWTAP IP address" of your board
and Pass the IP address of the machine where the Mac stub will be running.

  For example: 

       * if you want to run on Board 223, run the following command:

             source env223.sh 188

             where 188 is the IP of my virtual machine on subnet 2 and the Mac stub will run on my virtual machine.

	 you can then run a python testcase in the same terminal session.


The **Default** running mode in Mac-stub is infinite running with random input generation.


If you want to run with the input of the testcase, see the DL Testing part located in the last section.


For a finite Running (i.e. ending the scripts when the configurations are sent and IQs are ready), set 
the variable "INFINITE_FLAG" to 0 in "heavyLoad.py" 


If you want to test DL, you must:

   1- Reset the variable "GEN_RANDOM_INPUT" to 0 in "mac_script.py" and "heavyLoad.py" to disable random input 
      generation and load input from testcase folder.

   2- Reset the variable "INFINITE_FLAG" to 0 in "heavyLoad.py" to run until Output is ready in PHY.

   3- Get the folder of the testcase you want from the DL Test cases repo

   4- Place the test case folder beside the mac scripts (see the hierarchy tree shown below for more illustration)
      
      The folder hierarchy tree for one test case should be at least as the following:
			.
			├── env223.sh
			├── mac
			│   ├── heavyLoad.py
			│   ├── mac_script.py
			│   ├── multi_sector.py
			│   ├── pdsch.py
			│   ├── scapi_classes.py
			│   ├── scapi_l2.py
			│   ├── scapi.py
			│   └── test_gen.py
			└── TestCase6
			    ├── Checkpoints
			    ├── ConfigurationScripts
			    │   └── DL_Configuration_parameters_testcase6.py
			    ├── Input
			    │   ├── IF1_Tx_00_00_01.lod
			    │   └── PBCH_Input.lod
			    └── Output


