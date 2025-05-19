class ahb_xtn extends uvm_sequence_item;
	`uvm_object_utils(ahb_xtn)

	bit HRESETn;
	rand bit [31:0] HADDR;
	rand bit [1:0] HTRANS;
	rand bit HWRITE;
	rand bit [2:0] HSIZE;
	rand bit [2:0] HBURST;
	rand bit [31:0] HWDATA;
	bit [31:0] HRDATA;
	bit HREADYin;
	bit HREADYout;
	bit [1:0] HRESP;

	rand bit [9:0] length;

	constraint valid_addr 	{ HADDR inside {	[32'h8000_0000 : 32'h8000_03ff],
							[32'h8400_0000 : 32'h8400_03ff],
							[32'h8800_0000 : 32'h8800_03ff],
							[32'h8c00_0000 : 32'h8c00_03ff]};
				}
	
	constraint valid_size { HSIZE inside {0,1,2};}

	constraint aligned_addr {	(HSIZE == 1) -> HADDR % 2 == 0;
					(HSIZE == 2) -> HADDR % 4 == 0;
				}

	constraint boundar_addr { (HADDR % 1024) + (length * (2**HSIZE)) <= 1023;}

	constraint length_hburst {	HBURST == 0 -> length == 1;
					HBURST == 2 -> length == 4;
					HBURST == 3 -> length == 4;
					HBURST == 4 -> length == 8;
					HBURST == 5 -> length == 8;
					HBURST == 6 -> length == 16;
					HBURST == 7 -> length == 16;
				 }

	extern function new(string name = "ahb_xtn");
	extern function void do_print(uvm_printer printer);
endclass


//---------------------------Constructor new------------------------------
function ahb_xtn::new(string name = "ahb_xtn");
	super.new(name);
endfunction


//--------------------------------DO PRINT--------------------------------
function void ahb_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
	
	//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"	
	printer.print_field("HRESETn", this.HRESETn, 1, UVM_DEC);
	printer.print_field("HADDR", this.HADDR, 32, UVM_HEX);
	printer.print_field("HTRANS", this.HTRANS, 2, UVM_DEC);
	printer.print_field("HWRITE", this.HWRITE, 1, UVM_DEC);
	printer.print_field("HSIZE", this.HSIZE, 3, UVM_DEC);
	printer.print_field("HBURST", this.HBURST, 3, UVM_DEC);
	printer.print_field("HWDATA", this.HWDATA, 32, UVM_HEX);
	printer.print_field("HRDATA", this.HRDATA, 32, UVM_HEX);
	printer.print_field("HREADYin", this.HREADYin, 1, UVM_DEC);
	printer.print_field("HREADYout", this.HREADYout, 1, UVM_DEC);
	printer.print_field("HRESP", this.HRESP, 2, UVM_DEC);
	printer.print_field("length", this.length, 10, UVM_DEC);
endfunction
