class env_config extends uvm_object;
	`uvm_object_utils(env_config)

	ahb_agent_config ahb_agt_cfg[];
	apb_agent_config apb_agt_cfg[];

	int no_of_ahb_agt, no_of_apb_agt;
	int no_of_duts;
	bit has_scoreboard = 1;

	extern function new(string name = "env_config");
endclass

function env_config::new(string name = "env_config");
	super.new(name);
endfunction
