interface apb_if(input bit clock);
	logic PENABLE;
	logic PWRITE;
	logic [31:0] PWDATA;
	logic [31:0] PRDATA;
	logic [31:0] PADDR;
	logic [3:0] PSELx;

	clocking apb_drv@(posedge clock);
		default input #1 output #1;
		output PRDATA;
		input PENABLE, PWRITE, PSELx, PWDATA, PADDR;
	endclocking

	clocking apb_mon@(posedge clock);
		default input #1 output #1;
		input PRDATA, PENABLE, PWRITE, PSELx, PWDATA, PADDR;
	endclocking

	modport APB_DRV_MP (clocking apb_drv);
	modport APB_MON_MP (clocking apb_mon);

endinterface
