package bridge_pkg;


//import uvm_pkg.sv
	import uvm_pkg::*;
//include uvm_macros.sv
	`include "uvm_macros.svh"
//`include "tb_defs.sv"
`include "ahb_xtn.sv"
`include "ahb_agent_config.sv"
`include "apb_agent_config.sv"
`include "env_config.sv"
`include "ahb_driver.sv"
`include "ahb_monitor.sv"
`include "ahb_sequencer.sv"
`include "ahb_agent.sv"
`include "ahb_agent_top.sv"
`include "ahb_seqs.sv"

`include "apb_xtn.sv"
`include "apb_monitor.sv"
`include "apb_sequencer.sv"
//`include "apb_seqs.sv"
`include "apb_driver.sv"
`include "apb_agent.sv"
`include "apb_agent_top.sv"

//`include "virtual_sequencer.sv"
//`include "virtual_seqs.sv"
`include "bridge_sb.sv"

`include "bridge_tb.sv"


`include "test.sv"
endpackage

