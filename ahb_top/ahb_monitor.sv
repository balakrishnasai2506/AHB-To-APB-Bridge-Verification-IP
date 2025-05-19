class ahb_monitor extends uvm_monitor;
	`uvm_component_utils(ahb_monitor)
	
	//Virtual interface declaration
	virtual ahb_if.AHB_MON_MP hif;
	//Agent Config declaration
	ahb_agent_config ahb_agt_cfg;
	//Analysis port
	uvm_analysis_port#(ahb_xtn) ap;

	//Methods
	extern function new(string name = "ahb_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass


//----------------------------------Constructor new-----------------------------------------------
function ahb_monitor::new(string name = "ahb_monitor", uvm_component parent);
	super.new(name, parent);
	ap = new("ap", this); //Create memory for analysis port
endfunction 


//------------------------------------Build_phase()----------------------------------------------
function void ahb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the virtual interface from config class using uvm_config_db
	if(!uvm_config_db#(ahb_agent_config)::get(get_parent(),"","ahb_agent_config",ahb_agt_cfg))
		`uvm_fatal("AHB_MONITOR","Couldn't get agent config from uvm_config_db... Did you set it right???")
endfunction


//---------------------------------------Connect_Phase()-------------------------------------------
function void ahb_monitor::connect_phase(uvm_phase phase);
	hif = ahb_agt_cfg.hif;//Assign hif to config_handle's hif
endfunction


//--------------------------------------Run_Phase()------------------------------------------------
task ahb_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
	end
endtask


//--------------------------------------Collect_data()-----------------------------------------------
task ahb_monitor::collect_data();
	//Declare a handle for transaction class so that we can store the sampled data
	ahb_xtn xtn;

	//Create memory for txn class
	xtn = ahb_xtn::type_id::create("xtn");

	wait(hif.ahb_mon.HREADYout == 1 && (hif.ahb_mon.HTRANS == 2'b10 || hif.ahb_mon.HTRANS == 2'b11));
	xtn.HADDR = hif.ahb_mon.HADDR;
	xtn.HTRANS = hif.ahb_mon.HTRANS;
	xtn.HWRITE = hif.ahb_mon.HWRITE;
	xtn.HSIZE = hif.ahb_mon.HSIZE;
	xtn.HREADYin = hif.ahb_mon.HREADYin;

	@(hif.ahb_mon);
	//wait(hif.ahb_mon.HREADYout == 1 && (hif.ahb_mon.HTRANS == 2'b10 || hif.ahb_mon.HTRANS == 2'b11));
	wait(hif.ahb_mon.HREADYout == 1);
	if(hif.ahb_mon.HWRITE)
		xtn.HWDATA = hif.ahb_mon.HWDATA;
	else
		xtn.HRDATA = hif.ahb_mon.HRDATA;

	$display("--------------------------------DATA SAMPLED---------------------------------");
	xtn.print();

	ap.write(xtn);//Sending the sampled elements to SB using analysis port

endtask

