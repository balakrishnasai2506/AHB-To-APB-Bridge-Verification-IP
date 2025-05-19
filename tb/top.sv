module top;
	import uvm_pkg::*;
	import bridge_pkg::*;
	
	//CLOCK Generation
	bit clk;
	always #10 clk = ~clk;
	
	//Interface declaration
	ahb_if hif(clk);
	apb_if pif(clk);

	//DUT instantiation
	rtl_top top(
		.Hclk(clk),
                .Hresetn(hif.HRESETn),
                .Htrans(hif.HTRANS),
		.Hsize(hif.HSIZE), 
		.Hreadyin(hif.HREADYin),
		.Hwdata(hif.HWDATA), 
		.Haddr(hif.HADDR),
		.Hwrite(hif.HWRITE),
                .Prdata(pif.PRDATA),
		.Hrdata(hif.HRDATA),
		.Hresp(hif.HRESP),
		.Hreadyout(hif.HREADYout),
		.Pselx(pif.PSELx),
		.Pwrite(pif.PWRITE),
		.Penable(pif.PENABLE), 
		.Paddr(pif.PADDR),
		.Pwdata(pif.PWDATA)
			);


	initial begin
		//Setting the virtual interfaces into config db
		uvm_config_db#(virtual ahb_if)::set(null,"*","vif_h",hif);
		uvm_config_db#(virtual apb_if)::set(null,"*","vif_p",pif);
	
		//Run_test
		run_test();
	end

	//Assertions
	property stable_data;
		@(posedge clk) (hif.HREADYout == 0) |-> ($stable(hif.HADDR) && $stable(hif.HTRANS) && $stable(hif.HSIZE) && $stable(hif.HWRITE) && $stable(hif.HBURST));
	endproperty
	
	property pselx_val();
		@(posedge clk)
		@(posedge clk)
		$rose(pif.PSELx[0]) || $rose(pif.PSELx[1]) || $rose(pif.PSELx[2]) || $rose(pif.PSELx[3]) |=> (pif.PENABLE);
	endproperty 

	A1 : assert property(stable_data)
		$display("ASSERTION SUCCESS - STABLE DATA");
		else
		$display("ASSERTION FAILED - STABLE DATA");
	
	
	A2 : assert property(pselx_val)
		$display("ASSERTION SUCCESS - PSELx Property Asserted");
		else
		$display("ASSERTION FAILED - PSELx Property De-Asserted");
	
	A1_COV : cover property(stable_data);
	A2_COV : cover property(pselx_val);
endmodule
