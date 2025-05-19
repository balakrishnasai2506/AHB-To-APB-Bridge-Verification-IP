class ahb_agent_top extends uvm_env;
	`uvm_component_utils(ahb_agent_top) //Factory Registration

	//Declare Write Agent handle
	ahb_agent ahb_agnth[];

	//Declare a handle for env_config
	env_config e_cfg;

	//Standard Methods
	extern function new(string name = "ahb_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass


//---------------------------------Constructor "new"-------------------------------------
function ahb_agent_top::new(string name = "ahb_agent_top", uvm_component parent);
	super.new(name,parent);
endfunction


//---------------------------------Build Phase-------------------------------------
function void ahb_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	//Get the env_config from uvm_config_db
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("SOURCE_AGENT","Could not get ENV_CONFIG.... Did u set it???")

	ahb_agnth = new[e_cfg.no_of_ahb_agt];

	foreach(ahb_agnth[i]) begin
		ahb_agnth[i] = ahb_agent::type_id::create($sformatf("ahb_agnth[%0d]",i),this);
		uvm_config_db #(ahb_agent_config)::set(this,$sformatf("ahb_agnth[%0d]",i),"ahb_agent_config",e_cfg.ahb_agt_cfg[i]);
	end
endfunction

