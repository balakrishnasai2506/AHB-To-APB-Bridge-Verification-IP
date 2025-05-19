class apb_driver extends uvm_driver #(apb_xtn);
	`uvm_component_utils(apb_driver)
	
	virtual apb_if.APB_DRV_MP pif;
	apb_agent_config apb_agt_cfg;

	//Methods
	extern function new(string name = "apb_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut();
endclass


//---------------------Constructor new------------------------------------------
function apb_driver::new(string name = "apb_driver", uvm_component parent);
	super.new(name, parent);
endfunction


//----------------------Build_phase()-------------------------------
function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get agent config to retrieve VIF from uvm_config_db
	if(!uvm_config_db#(apb_agent_config)::get(get_parent(), "", "apb_agent_config", apb_agt_cfg))
		`uvm_fatal("APB_DRIVER","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//--------------------------------------Connect_phase()-------------------------------------------
function void apb_driver::connect_phase(uvm_phase phase);
	pif = apb_agt_cfg.pif;
endfunction


//-------------------------------------Run_Phase()-----------------------------------------
task apb_driver::run_phase(uvm_phase phase);
	forever begin
		send_to_dut();
	end
endtask


//--------------------------------------Send_to_dut------------------------------------------
task apb_driver::send_to_dut();
	wait(pif.apb_drv.PSELx == 1 || 2 || 4 || 8);
	if(pif.apb_drv.PWRITE == 0)
		pif.apb_drv.PRDATA <= $random;
	
	repeat(2)
	@(pif.apb_drv);

endtask
