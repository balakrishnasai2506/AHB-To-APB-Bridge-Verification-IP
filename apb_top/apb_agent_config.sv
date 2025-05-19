class apb_agent_config extends uvm_object;

	`uvm_object_utils(apb_agent_config) //Factory Registration

	//virtual interface handle declaration
	virtual apb_if pif;

	//Data Member
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	//Methods
	extern function new(string name = "apb_agent_config");

endclass

//-------------Constructor "new"-------------

function apb_agent_config::new(string name = "apb_agent_config");
	super.new(name);
endfunction

