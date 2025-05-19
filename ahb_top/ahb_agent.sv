class ahb_agent extends uvm_agent;
	`uvm_component_utils(ahb_agent) //Factory Registration

	//Declare the handles for driver, monitor and sequencer
	ahb_driver ahb_drvh;
	ahb_monitor ahb_monh;
	ahb_sequencer ahb_seqrh;

	//Declare the handle for source_agent_config
	ahb_agent_config ahb_agt_cfg;

	//Standard Methods
	extern function new(string name = "ahb_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//------------------------------Constructor "new"---------------------------------
function ahb_agent::new(string name = "ahb_agent", uvm_component parent);
	super.new(name,parent);
endfunction


//------------------------------Build Phase---------------------------------
function void ahb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config from uvm_config_db
	if(!uvm_config_db #(ahb_agent_config)::get(this,"","ahb_agent_config",ahb_agt_cfg))
		`uvm_fatal("AHB AGENT","Could not get AGENT_CONFIG.... Did u set it???")

	//Create object for monitor
	ahb_monh = ahb_monitor::type_id::create("ahb_monh",this);

	//Create objects for driver and sequencer if is_active is UVM_ACTIVE
	if(ahb_agt_cfg.is_active == UVM_ACTIVE) begin
		ahb_drvh = ahb_driver::type_id::create("ahb_drvh",this);
		ahb_seqrh = ahb_sequencer::type_id::create("ahb_seqrh",this);
	end

endfunction


//------------------------------Connect Phase---------------------------------
function void ahb_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	ahb_drvh.seq_item_port.connect(ahb_seqrh.seq_item_export);
endfunction

