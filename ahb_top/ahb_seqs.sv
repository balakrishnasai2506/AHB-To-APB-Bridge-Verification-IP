//-----------------------Base Sequence----------------------------------
class ahb_seqs extends uvm_sequence#(ahb_xtn);
	`uvm_object_utils(ahb_seqs) //Factory registration

	//Local variables
	bit [31:0]haddr;
  	bit [2:0]hsize;
	bit [2:0]hburst;
  	bit hwrite;
  	bit [9:0] hlength;

	//Methods
	extern function new(string name = "ahb_seqs");

endclass

//-------------------------------Constructor new----------------------------------
function ahb_seqs::new(string name = "ahb_seqs");
	super.new(name);
endfunction



//-------------------------------INCR Sequence---------------------------------
class incr_seqs extends ahb_seqs;
	`uvm_object_utils(incr_seqs)
	
	//Methods
	extern function new(string name = "incr_seqs");
	extern task body();
endclass

//----------------Constructor new------------------------
function incr_seqs::new(string name = "incr_seqs");
	super.new(name);
endfunction

//-------------------Body()-----------------------
task incr_seqs::body();

	req=ahb_xtn::type_id::create("req");

//	repeat(70) begin
		start_item(req);

		assert(req.randomize() with {HTRANS==2'b10;
      			HBURST inside{3,5,7};});
		finish_item(req);


		haddr=req.HADDR;
		hwrite=req.HWRITE;
		hsize=req.HSIZE;
		hburst=req.HBURST;
		hlength=req.length;

		for(int i=1; i<hlength; i=i+1) begin
			start_item(req);
			assert(req.randomize() with {HTRANS==2'b11;
      				HWRITE==hwrite;
      				HSIZE==hsize;
      				HBURST==hburst;
      				HADDR==haddr+(2**hsize);});
			finish_item(req);

			haddr=req.HADDR;
		end
//	end
endtask



//-------------------------------WRAP Sequence---------------------------------
class wrap_seqs extends ahb_seqs;
	`uvm_object_utils(wrap_seqs)
	
	//Local variables
	bit [31:0] start_addr, boundary_addr;

	//Methods
	extern function new(string name = "wrap_seqs");
	extern task body();
endclass

//----------------Constructor new------------------------
function wrap_seqs::new(string name = "wrap_seqs");
	super.new(name);
endfunction

//-------------------Body()-----------------------
task wrap_seqs::body();
	req = ahb_xtn::type_id::create("req");
	
//	repeat(70) begin
	//For Non-Sequential transfer
	start_item(req);
	assert(req.randomize() with {HTRANS == 2'b10; HBURST inside {2, 4, 6};});
	finish_item(req);
	
	//store the address, burst and all into local variables
	haddr = req.HADDR;
	hsize = req.HSIZE;
	hburst = req.HBURST;
	hwrite = req.HWRITE;
	hlength = req.length;
	start_addr= int'(haddr/((2**hsize)*(hlength)))*((2**hsize)*(hlength));
	boundary_addr = start_addr + ((2**hsize)*(hlength));
	`uvm_info("START_ADDR",$sformatf("Starting address for the WRAPING Memory block : %0h",start_addr),UVM_MEDIUM)
	`uvm_info("BOUNDARY_ADDR",$sformatf("BOUNDARY address for the WRAPING Memory block : %0h",boundary_addr),UVM_MEDIUM)
	
	haddr = req.HADDR + (2**hsize);

	//For Sequential Transfers
	for(int i = 1; i < hlength; i++) begin
		if(haddr == boundary_addr)
			haddr = start_addr;
		start_item(req);
        	assert(req.randomize() with {HTRANS == 2'b11; HSIZE == hsize; HWRITE == hwrite; HBURST == hburst; HADDR == haddr;});
        	finish_item(req);
		haddr = req.HADDR + (2**hsize);
	end
//	end
endtask
