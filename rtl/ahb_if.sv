interface ahb_if(input bit clock);
	logic HRESETn;
	logic [31:0] HADDR;
	logic [1:0] HTRANS;
	logic HWRITE;
	logic [2:0] HSIZE;
	logic [2:0] HBURST;
	logic [31:0] HWDATA;
	logic [31:0] HRDATA;
	logic HREADYin;
	logic HREADYout;
	logic [1:0] HRESP;
	logic HSELAPB;

	clocking ahb_drv@(posedge clock);
		default input #1 output #1;
		output HRESETn, HTRANS, HWRITE, HSELAPB, HREADYin, HWDATA, HADDR, HSIZE, HBURST;
		input HREADYout, HRDATA;
	endclocking

	clocking ahb_mon@(posedge clock);
		default input #1 output #1;
		input HRESETn, HTRANS, HWRITE, HSELAPB, HREADYin, HWDATA, HADDR, HSIZE, HBURST, HREADYout, HRDATA, HRESP;
	endclocking

	modport AHB_DRV_MP (clocking ahb_drv);
	modport AHB_MON_MP (clocking ahb_mon);

endinterface
