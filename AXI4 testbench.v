initial begin
    $dumpfile("axi4_master.vcd");
    $dumpvars(0, axi4_master_interface);

    reset_system();
    send_write_transaction('h1000_0000, 'hDEADBEEF); // 地址=0x10000000, 数据=0xDEADBEEF
    send_read_transaction('h1000_0000);              // 地址=0x10000000
    #100 $finish;
end

task reset_system;
begin
    clk = 0;
    rst = 0;
    #(CLK_PERIOD * 2);
    rst = 1;
    repeat (5) @(posedge clk);
    rst = 0;
end
endtask

task send_write_transaction(input [31:0] addr, data);
// 设置写地址和数据...
endtask

task send_read_transaction(input [31:0] addr);
// 设置读地址...
endtask