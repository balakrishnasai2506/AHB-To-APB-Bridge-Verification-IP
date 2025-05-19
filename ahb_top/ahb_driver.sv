class ahb_driver extends uvm_driver#(ahb_xtn);
	`uvm_component_utils(ahb_driver)

	virtual ahb_if.AHB_DRV_MP hif;
	ahb_agent_config ahb_agt_cfg;

	//Methods
	extern function new(string name = "ahb_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(ahb_xtn xtn);
endclass

//--------------------Constructor new------------------------------
function ahb_driver::new(string name = "ahb_driver", uvm_component parent);
	super.new(name, parent);
endfunction

//-----------------------------Build_Phase()-----------------------------------------
function void ahb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	//Get the agent config to retrieve VIF
	if(!uvm_config_db#(ahb_agent_config)::get(get_parent(),"","ahb_agent_config",ahb_agt_cfg))
		`uvm_fatal("AHB_DRIVER","Couldn't get AGENT CONFIG from UVM_CONFIG_DB... Did u set it right???")
endfunction


//---------------------------------Connect_Phase()----------------------------------------
function void ahb_driver::connect_phase(uvm_phase phase);
	hif = ahb_agt_cfg.hif; //Assigning the agent config's virtual interface handle to driver's virtual interface handle
endfunction


//--------------------------------Run_phase()-------------------------------------------
task ahb_driver::run_phase(uvm_phase phase);
	//Reset Logic
	@(hif.ahb_drv);
	hif.ahb_drv.HRESETn <= 1'b0;
	@(hif.ahb_drv);
	hif.ahb_drv.HRESETn <= 1'b1;

	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
		$display("-----------------------DATA DRIVEN--------------------------");
		req.print();
	end
endtask


//---------------------------Send To DUT()----------------------------------------------
task ahb_driver::send_to_dut(ahb_xtn xtn);
	
	//Address Phase
	wait(hif.ahb_drv.HREADYout == 1);
	hif.ahb_drv.HADDR <= xtn.HADDR;
	hif.ahb_drv.HTRANS <= xtn.HTRANS;
	hif.ahb_drv.HSIZE <= xtn.HSIZE;
	hif.ahb_drv.HWRITE <= xtn.HWRITE;
	hif.ahb_drv.HREADYin <= 1'b1;

	@(hif.ahb_drv);
	wait(hif.ahb_drv.HREADYout == 1);
	if(xtn.HWRITE) 
		hif.ahb_drv.HWDATA <= xtn.HWDATA;
	else
		hif.ahb_drv.HWDATA <= 32'b0;
endtask

