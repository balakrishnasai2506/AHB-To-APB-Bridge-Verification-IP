class bridge_test extends uvm_test;

	`uvm_component_utils(bridge_test) //Factory Registration

	//Declare Agent and Env config handles(Agent Cfgs as dynamic as the destination has 3 agents)
	ahb_agent_config ahb_agt_cfg[];
	apb_agent_config apb_agt_cfg[];
	env_config e_cfg;

	//Declare router_env handle
	bridge_tb env;

	int no_of_wagts = 1; //Source agent
	int no_of_ragts = 1; //Destination agents

	int has_sagt = 1;
	int has_dagt = 1;
	int no_of_duts = 1;

	//Methods
	extern function new(string name = "bridge_test",uvm_component parent);
	extern function void config_bridge();
	extern function void build_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass


//-------------------------------Constructor "new"--------------------------------------
function bridge_test::new(string name = "bridge_test",uvm_component parent);
	super.new(name,parent);
endfunction


//-------------------------------config_bridge() method--------------------------------------
function void bridge_test::config_bridge();
	if(has_sagt) begin
		ahb_agt_cfg = new[no_of_wagts];
		foreach(ahb_agt_cfg[i]) begin
			ahb_agt_cfg[i] = ahb_agent_config::type_id::create($sformatf("ahb_agt_cfg[%d]",i));
			if(!uvm_config_db#(virtual ahb_if)::get(this, "", "vif_h", ahb_agt_cfg[i].hif))
				`uvm_fatal("VIF_CONG AT AHB","cannot get() interface from uvm_config_db, did you set it right?");
		$display("-----------------------%p",ahb_agt_cfg[i]);
			ahb_agt_cfg[i].is_active = UVM_ACTIVE;
				e_cfg.ahb_agt_cfg[i] = ahb_agt_cfg[i];
		end
	end

	
	if(has_dagt) begin
                apb_agt_cfg = new[no_of_ragts];
                foreach(apb_agt_cfg[i]) begin
                        apb_agt_cfg[i] = apb_agent_config::type_id::create($sformatf("apb_agt_cfg[%d]",i));
                        if(!uvm_config_db#(virtual apb_if)::get(this,"", "vif_p",apb_agt_cfg[i].pif))
                                `uvm_fatal("VIF_CONG AT APB","cannot get() interface from uvm_config_db, did you set it right?");
                $display("-----------------------%p",apb_agt_cfg[i]);
                        apb_agt_cfg[i].is_active = UVM_ACTIVE;
                                e_cfg.apb_agt_cfg[i] = apb_agt_cfg[i];
                end
        end

	e_cfg.no_of_ahb_agt = no_of_wagts;
	e_cfg.no_of_apb_agt = no_of_ragts;
	e_cfg.no_of_duts = no_of_duts;
endfunction


//-------------------------------build_phase() method--------------------------------------
function void bridge_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Create object for env config class
	e_cfg = env_config::type_id::create("e_cfg");
	
	//Check whether env_cfg contains src &dst_agt_cfgs and create objects for those classes
	if(has_sagt)
		e_cfg.ahb_agt_cfg = new[no_of_wagts];

	if(has_dagt)
		e_cfg.apb_agt_cfg = new[no_of_ragts];

	config_bridge(); // Call config_router() method to get the virtual interfaces for respective agent cfgs

	uvm_config_db#(env_config)::set(this,"*","env_config",e_cfg); //Setting env_cfg into uvm_config_db

	env = bridge_tb::type_id::create("env",this);

endfunction
		

//-------------------------------end_of_elaboration_phase()--------------------------------------
function void bridge_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
endfunction


//------------------------------------INCR Test------------------------------------------------
class incr_test extends bridge_test;
	`uvm_component_utils(incr_test)
	//small_vseq seq1;
	incr_seqs seq1;
	//normal_sequence seq1h;

	//Methods
	extern function new(string name = "incr_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function incr_test::new(string name = "incr_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void incr_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task incr_test::run_phase(uvm_phase phase);
		//Create object for seq1 using "create" method
		seq1 = incr_seqs::type_id::create("seq1");

		phase.raise_objection(this);
			seq1.start(env.ahb_agt_top.ahb_agnth[0].ahb_seqrh);
//			#500;
		phase.drop_objection(this);
endtask


//------------------------------------WRAP Test------------------------------------------------
class wrap_test extends bridge_test;
	`uvm_component_utils(wrap_test)
	wrap_seqs seq2;

	//Methods
	extern function new(string name = "wrap_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass


//--------------------------------Constructor "new"----------------------------------------
function wrap_test::new(string name = "wrap_test", uvm_component parent);
	super.new(name, parent);
endfunction


//--------------------------------Build Phase()--------------------------------------------
function void wrap_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction


//--------------------------------Run Phase()--------------------------------------------
task wrap_test::run_phase(uvm_phase phase);
		//Create object for seq1 using "create" method
		seq2 = wrap_seqs::type_id::create("seq2");

		phase.raise_objection(this);
			seq2.start(env.ahb_agt_top.ahb_agnth[0].ahb_seqrh);
//			#500;
		phase.drop_objection(this);
endtask
