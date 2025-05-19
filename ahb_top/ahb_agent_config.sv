class ahb_agent_config extends uvm_object;

	`uvm_object_utils(ahb_agent_config) // Factory Registration

	//Virtual interface handle declaration
	virtual ahb_if hif;

	//Data Member
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	
	//Methods
	extern function new(string name = "ahb_agent_config");
endclass

//-----------------Constructor "new"-------------------------------
function ahb_agent_config::new(string name = "ahb_agent_config");
	super.new(name);
endfunction


