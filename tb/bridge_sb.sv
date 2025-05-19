class bridge_sb extends uvm_scoreboard;
	`uvm_component_utils(bridge_sb) //Factory Registration
	
	//Declare TLM Analysis fifo to store monitor data
	uvm_tlm_analysis_fifo#(ahb_xtn) ahb_fifo[];
	uvm_tlm_analysis_fifo#(apb_xtn) apb_fifo[];

	//Declare handles for ahb and apb xtns for storing the fifo data
	ahb_xtn ahb;
	apb_xtn apb;

	env_config e_cfg; // ENV CONFIG handle declaration
	int data_verified; //For keeping a count of checks
	
	//Methods
	extern function new(string name = "bridge_sb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task compare(int haddr, paddr, hdata, pdata);
	extern task bridge_check(ahb_xtn ahb, apb_xtn apb);
	extern function void report_phase(uvm_phase phase);

	 //Covergroup Declarations
          covergroup ahb_cov;
                option.per_instance = 1;
                ADDR: coverpoint ahb.HADDR      {
                                                          bins slave1 = {[32'h8000_0000: 32'h8000_03ff]};
                                                          bins slave2 = {[32'h8400_0000: 32'h8400_03ff]};
                                                          bins slave3 = {[32'h8c00_0000: 32'h8c00_03ff]};
                                                }
 
                SIZE: coverpoint ahb.HSIZE      {
                                                          bins byte_1 = {0};
                                                          bins bytes_2 = {1};
                                                          bins bytes_4 = {2};
                                                }
 
                WR_CTRL: coverpoint ahb.HWRITE  {
                                                          bins wr = {1};
                                                          bins rd = {0};
                                                }

		TRANS: coverpoint ahb.HTRANS	{
							bins non_seq = {2'b10};
							bins seq = {2'b11};
						}

		ADDRXSIZEXWR_CTRLXTRANS: cross ADDR, SIZE, WR_CTRL, TRANS;
	endgroup 

          covergroup apb_cov;
                option.per_instance = 1;
                ADDR: coverpoint apb.PADDR      {
                                                          bins slave1 = {[32'h8000_0000: 32'h8000_03ff]};
                                                          bins slave2 = {[32'h8400_0000: 32'h8400_03ff]};
                                                          bins slave3 = {[32'h8c00_0000: 32'h8c00_03ff]};
                                                }

		SEL: coverpoint apb.PSELx	{
							bins first_slave = {4'b0001};
                                                     	bins second_slave = {4'b0010};
                                                     	bins third_slave = {4'b0100};
                                          	        bins fourth_slave = {4'b1000};
						}

                WR_CTRL: coverpoint apb.PWRITE  {
                                                          bins wr = {1};
                                                          bins rd = {0};
                                                }
       		ADDRXSELXWR_CTRL: cross ADDR, SEL, WR_CTRL;
	 endgroup
endclass

//-----------------------------Constructor "new"-----------------------------------
function bridge_sb::new(string name = "bridge_sb", uvm_component parent);
	super.new(name, parent);
	ahb_cov = new;
	apb_cov = new;
endfunction

//----------------------------Build Phase()---------------------------------------
function void bridge_sb::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(env_config)::get(this, "", "env_config", e_cfg))
		 `uvm_fatal("SCOREBOARD","Couldn't get ENV_CONFIG from uvm_config_db... Did you set it right???")

	ahb_fifo = new[e_cfg.no_of_ahb_agt];
	foreach(ahb_fifo[i]) begin
		ahb_fifo[i] = new($sformatf("ahb_fifo[%0d]",i), this);
	end

	apb_fifo = new[e_cfg.no_of_apb_agt];
	foreach(apb_fifo[i]) begin
		apb_fifo[i] = new($sformatf("apb_fifo[%0d]",i), this);
	end
endfunction

//--------------------------------Run Phase()--------------------------------------
task bridge_sb::run_phase(uvm_phase phase);
	forever begin
		fork begin
			ahb_fifo[0].get(ahb);
			ahb.print();
			ahb_cov.sample();
		end

		begin
			apb_fifo[0].get(apb);
			apb.print();
			apb_cov.sample();
		end
		join
		bridge_check(ahb,apb);
	end
endtask

//-------------------------------Compare()------------------------------------------
task bridge_sb::compare(int haddr, paddr, hdata, pdata);
	if(haddr == paddr)
		$display("ADDRESS COMPARED SUCCESSFULLY");
	else
		$display("ADDRESS COMPARISON FAILED");

	if(hdata == pdata)
		$display("DATA COMPARED SUCCESSFULLY");
	else
		$display("DATA COMPARISON FAILED");
endtask

//------------------------------Check()--------------------------------------------
task bridge_sb::bridge_check(ahb_xtn ahb, apb_xtn apb);
	if(ahb.HWRITE == 1) begin
		if(ahb.HSIZE == 2'b00) begin
			if(ahb.HADDR[1:0] == 2'b00)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[7:0], apb.PWDATA);
			if(ahb.HADDR[1:0] == 2'b01)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[15:8], apb.PWDATA);
			if(ahb.HADDR[1:0] == 2'b10)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[23:16], apb.PWDATA);
			if(ahb.HADDR[1:0] == 2'b11)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[31:24], apb.PWDATA);
		end

		if(ahb.HSIZE == 2'b01) begin
			if(ahb.HADDR[1:0] == 2'b00)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[15:0], apb.PWDATA);
			if(ahb.HADDR[1:0] == 2'b10)
				compare(ahb.HADDR, apb.PADDR, ahb.HWDATA[31:16], apb.PWDATA);
		end

		if(ahb.HSIZE == 2'b10) begin
			compare(ahb.HADDR, apb.PADDR, ahb.HWDATA, apb.PWDATA);
		end
	end

	if(ahb.HWRITE == 0) begin
		if(ahb.HSIZE == 2'b00) begin
			if(ahb.HADDR[1:0] == 2'b00)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[7:0]);
			if(ahb.HADDR[1:0] == 2'b01)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[15:8]);
			if(ahb.HADDR[1:0] == 2'b10)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[23:16]);
			if(ahb.HADDR[1:0] == 2'b11)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[31:24]);
		end

		if(ahb.HSIZE == 2'b01) begin
			if(ahb.HADDR[1:0] == 2'b00)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[15:0]);
			if(ahb.HADDR[1:0] == 2'b10)
				compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA[31:16]);
		end

		if(ahb.HSIZE == 2'b10) begin
			compare(ahb.HADDR, apb.PADDR, ahb.HRDATA, apb.PRDATA);
		end
	end
	
	data_verified++;
endtask

//-----------------------------------Report_phase()--------------------------------------------
function void bridge_sb::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("SCOREBOARD REPORT:\n DATA VERIFIED = %0d\n", data_verified), UVM_LOW)
endfunction
