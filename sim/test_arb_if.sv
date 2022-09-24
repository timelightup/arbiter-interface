

interface arb_if (input bit clk);
	logic [1:0] grant, request;
	bit rst;

        clocking cb @(posedge clk);
                output request;
                input grant;
        endclocking


        modport TEST (output request, rst,
                      input grant, clk);
        modport DUT (input request, rst, clk,
                     output grant);
        modport MON (input request, rst, clk,
                     output grant);
        modport TESTCB (clocking cb,
                        output rst);
endinterface


module monitor (arb_if.MON arbif);
        always @(posedge arbif.request[0]) begin
                $display("@%0t: request[0] asserted", $time);
                @(posedge arbif.grant[0]);
                $display("@%0t: grant[0] asserted", $time);
        end

        always @(posedge arbif.request[1]) begin
                $display("@%0t: request[1] asserted", $time);
                @(posedge arbif.grant[1]);
                $display("@%0t: grant[1] asserted", $time);
        end
endmodule

/*module test_with_ifc (arb_if.TEST arbif);
        initial begin
                @(posedge arbif.clk);
                arbif.request <= 2'b10;
                $display("@%0t: Drove req=01", $time);
                repeat (2) @(posedge arbif.clk);
                if (arbif.grant == 2'b10)
                        $display("@%0t: Success: grant == 2'b01", $time);
                else
                        $display("@%0t: Error: grant != 2'b01", $time);
        end
endmodule*/

module automatic test_with_cb (arb_if.TESTCB arbif);
        initial begin
                @arbif.cb;
                arbif.cb.request <= 2'b01;
                $display("@%0t Drove req = 01", $time);
                repeat (2) @arbif.cb;
                a1: assert (arbif.cb.grant == 2'b01) $info("Grant assert");
                else $error("Grant not assert");
                if (arbif.cb.grant == 2'b01)
                        $display("@%0t: Success: grant = %b", $time, arbif.cb.grant);
                else
                        $display("@%0t: Error: grant = %b", $time, arbif.cb.grant);
        end
endmodule

module top;
        bit clk;
        initial begin
                forever #50     clk = ~clk;
        end

	arb_if	arbif(clk);
        arb_with_ifc a1 (arbif.DUT);
        //test_with_ifc t1 (arbif.TEST);
        test_with_cb t1(arbif.TESTCB);
        monitor m1 (arbif.MON);
endmodule