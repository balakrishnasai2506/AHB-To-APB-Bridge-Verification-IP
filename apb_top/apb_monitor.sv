class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)

	virtual apb_if.APB_MON_MP pif;
	apb_agent_config apb_agt_cfg;
	uvm_analysis_port#(apb_xtn) ap;

	//Methods
	extern function new(string name = "apb_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass

function apb_monitor::new(string name = "apb_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this);

endfunction


//----------------------Build_phase()-------------------------------
function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get agent config to retrieve VIF from uvm_config_db
	if(!uvm_config_db#(apb_agent_config)::get(get_parent(), "", "apb_agent_config", apb_agt_cfg))
		`uvm_fatal("APB_MONITOR","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//--------------------------------------Connect_phase()-------------------------------------------
function void apb_monitor::connect_phase(uvm_phase phase);
	pif = apb_agt_cfg.pif;
endfunction


//-------------------------------------Run_Phase()-----------------------------------------
task apb_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
	end
endtask


//--------------------------------------Collect_data()-----------------------------------------------
task apb_monitor::collect_data();
	//Declare a handle for transaction class so that we can store the sampled data
	apb_xtn xtn;

	//Create memory for txn class
	xtn = apb_xtn::type_id::create("xtn");
	
//	@(pif.apb_mon);
	wait(pif.apb_mon.PENABLE == 1);
	xtn.PADDR = pif.apb_mon.PADDR;
	xtn.PWRITE = pif.apb_mon.PWRITE;
	xtn.PSELx = pif.apb_mon.PSELx;
	
	if(xtn.PWRITE == 1)
		xtn.PWDATA = pif.apb_mon.PWDATA;
	else
		xtn.PRDATA = pif.apb_mon.PRDATA;
	
	@(pif.apb_mon);

	$display("--------------------------APB DATA SAMPLED----------------------------------");
	xtn.print();

	ap.write(xtn);
endtask
