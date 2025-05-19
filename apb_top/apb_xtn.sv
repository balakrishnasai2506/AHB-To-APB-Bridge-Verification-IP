class apb_xtn extends uvm_sequence_item;
	`uvm_object_utils(apb_xtn) //Factory Registration
	
	//Data Members
	bit PENABLE, PWRITE;
	bit [31:0] PADDR, PWDATA;
	rand bit [31:0] PRDATA;
	bit [3:0] PSELx;

	//--------------------------Constructor new------------------------------
	function new(string name = "apb_xtn");
		super.new(name);
	endfunction


	//--------------------------DO_PRINT()-----------------------------------
	function void do_print(uvm_printer printer);
		super.do_print(printer);
		//Print the variables
			//  "string"		"bitstream_value"	"size"		"radix for printing"	
		printer.print_field("PENABLE", this.PENABLE, 1, UVM_DEC);
		printer.print_field("PADDR", this.PADDR, 32, UVM_HEX);
		printer.print_field("PWRITE", this.PWRITE, 1, UVM_DEC);
		printer.print_field("PWDATA", this.PWDATA, 32, UVM_HEX);
		printer.print_field("PRDATA", this.PRDATA, 32, UVM_HEX);
		printer.print_field("PSELx", this.PSELx, 32, UVM_HEX);
	endfunction

endclass

