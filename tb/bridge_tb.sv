class bridge_tb extends uvm_env;
	`uvm_component_utils(bridge_tb) //Factory Registration

	//Declare low level TB Component handles such as agt tops
	ahb_agent_top ahb_agt_top;
	apb_agent_top apb_agt_top;

	//Declare handle for env_cfg
	env_config e_cfg;
	
	//Declare handle for virtual sequencer
//	virtual_sequencer vseqr;

	//Declare dynamic handle for scoreboard
	bridge_sb sb[];

	//Standard UVM Methods
	extern function new(string name = "bridge_tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass


//-----------------------------Constructor "new"--------------------------------
function bridge_tb::new(string name = "bridge_tb", uvm_component parent);
	super.new(name,parent);
endfunction


//-----------------------------Build Phase--------------------------------
function void bridge_tb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(env_config)::get(this,"*","env_config",e_cfg))
		`uvm_fatal("BRIDGE_TB","Could not get env_config from uvm_config_db... did u set it?")

	//Create objects for both source and destination agt tops
	begin
		ahb_agt_top = ahb_agent_top::type_id::create("ahb_agt_top",this);
	end

	begin
		apb_agt_top = apb_agent_top::type_id::create("apb_agt_top",this);
	end
/*
	//Create object for virtual sequencer
	if(e_cfg.has_virtual_sequencer)
		vseqr = virtual_sequencer::type_id::create("vseqr",this);
*/
	if(e_cfg.has_scoreboard) begin
		sb = new[e_cfg.no_of_duts];
	
		foreach(sb[i])
			sb[i] = bridge_sb::type_id::create($sformatf("sb[%0d]",i), this);
	end
endfunction


//--------------------------Connect Phase()-----------------------------
function void bridge_tb::connect_phase(uvm_phase phase);
	//Connect the sub sequencers in virtual sequencer to the physical src and dst sequencers
/*	if(e_cfg.has_virtual_sequencer) begin
		begin
			for(int i = 0; i< e_cfg.no_of_src_agt; i++)
				vseqr.src_seqr[i] = sagt_top.src_agnth[i].s_seqrh;
		end

		begin
			for(int i = 0; i< e_cfg.no_of_dst_agt; i++)
				vseqr.dst_seqr[i] = dagt_top.dst_agnth[i].d_seqrh;
		end
	end
*/
	//Connect scoreboard to monitor here...
	if(e_cfg.has_scoreboard) begin
		//AHB
		ahb_agt_top.ahb_agnth[0].ahb_monh.ap.connect(sb[0].ahb_fifo[0].analysis_export);

		//Destination
		apb_agt_top.apb_agnth[0].apb_monh.ap.connect(sb[0].apb_fifo[0].analysis_export);
		//dagt_top.dst_agnth[1].d_monh.ap.connect(sb[0].fifo_dst[1].analysis_export);
		//dagt_top.dst_agnth[2].d_monh.ap.connect(sb[0].fifo_dst[2].analysis_export);
	end
	
endfunction

