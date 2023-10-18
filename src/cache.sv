
module cache #(
    parameter AddrBusWidth = 32,
    parameter CacheBusWidth = 32,
    parameter MemBusWidth = 64,
    parameter N = 256 // number of cache blocks
) (
    input logic clk,
    input logic rst,

    // cpu interface
    input logic[AddrBusWidth-1:0] addr,
    output logic[CacheBusWidth-1:0] data,
    input logic re,
    output reg busy,
    output reg done,

    // memory interface
    output reg [AddrBusWidth-1:0] mem_addr,
    input logic [MemBusWidth-1:0] mem_data,
    input logic mem_busy,
    output logic mem_avail,
    input logic mem_done
);

localparam WordBits = $clog2(CacheBusWidth) - 3;
localparam Blocks = (MemBusWidth/CacheBusWidth);
localparam BlockBits = $clog2(Blocks);
localparam IndexBits = $clog2(N);
localparam TagBits = AddrBusWidth - IndexBits - BlockBits - WordBits;

wire [TagBits-1:0]   addr_tag = addr[AddrBusWidth-1:AddrBusWidth - TagBits];
wire [IndexBits-1:0] addr_index = addr[(WordBits+BlockBits+IndexBits-1):(WordBits+BlockBits)];
wire [BlockBits-1:0] addr_bs = addr[WordBits+BlockBits-1:WordBits];

reg [TagBits-1:0]     tag[N-1:0];
reg                   valid[N-1:0];
reg [Blocks-1:0] [CacheBusWidth-1:0] mem [N-1:0];

wire cache_hit = valid[addr_index] & tag[addr_index] == addr_tag;

typedef enum [1:0] {
    IDLE       = 'b00, // no memory access
    READ_MISS  = 'b01, // Initiate memory access following a read miss
    READ_MEM   = 'b10, // Main memory read in progress
    READ_DATA  = 'b11  // Data available from main memory read
} state_t;

reg read_cache;
reg write_cache;

reg [TagBits-1:0]   current_tag;
reg [IndexBits-1:0] current_index;
reg [BlockBits-1:0] current_bs;

reg [TagBits-1:0]   next_current_tag;
reg [IndexBits-1:0] next_current_index;
reg [BlockBits-1:0] next_current_bs;

reg [IndexBits-1:0] write_index;
reg [BlockBits-1:0] write_bs;
reg [MemBusWidth-1:0] write_data;

reg [IndexBits-1:0] valid_index;
reg                 valid_flag;
reg [TagBits-1:0]   valid_tag;

reg next_done;

state_t state;
state_t next_state;

always @ (posedge clk) begin
    if(rst) begin
        data <= 0;
    end else if(read_cache) begin
        data <= mem[addr_index][addr_bs];
    end else begin
        data <= 0;
    end
end

always @ (posedge clk) begin
    if(!rst && write_cache) begin
        mem[write_index] <= write_data;
    end
end

always @(posedge clk) begin
    if(rst) begin
        busy <= 1'b0;
    end if(!busy) begin
        if(!next_done && re) begin
            busy <= 1'b1;
        end
    end if(next_done) begin
            busy <= 1'b0;
    end
end

always @(posedge clk) begin
    if(rst) begin
        for(integer k = 0; k < N; k = k + 1) begin
            valid[k] = 0'b0;
        end

        state <= IDLE;
        current_tag <= 0;
        current_index <= 0;
        current_bs <= 0;
        done <= 1'b0;
        busy <= 1'b0;
    end else begin
        if(valid_flag) begin
            valid[valid_index] <= 1;
            tag[valid_index] <= valid_tag;
        end

        done <= next_done;
        state <= next_state;
        current_tag <= next_current_tag;
        current_index <= next_current_index;
        current_bs <= next_current_bs;
    end
end

always @(*) begin
    next_state = state;
    next_done = 1'b0;

    next_current_tag = current_tag;
    next_current_index = current_index;
    next_current_bs = current_bs;

    read_cache = 1'b0;
    write_cache = 1'b0;
    write_index = 0;
    write_data = 0;
    write_bs = 0;

    valid_index = 0;
    valid_tag = 0;
    valid_flag = 1'b0;

    mem_avail = 1'b0;
    mem_addr = '0;

    case(state)
    IDLE: begin
        if(cache_hit) begin
            read_cache = 1'b1;
            next_done = 1'b1;
        end else begin
            next_state = READ_MISS;
            next_current_tag = addr_tag;
            next_current_index = addr_index;
            next_current_bs = addr_bs;
            valid_index = addr_index;
            valid_flag = 1'b1;
            valid_tag = addr_tag;
        end
    end

    READ_MISS: begin
        if(!mem_busy) begin
            mem_avail = 1'b1;
            mem_addr = {current_tag, current_index, current_bs, {WordBits{1'b0}}};
            next_state = READ_MEM;
        end
    end

    READ_MEM: begin
        if(mem_done) begin
            write_cache = 1'b1;
            write_index = current_index;
            write_bs = current_bs;
            write_data = mem_data;

            mem_avail = 1'b1;
            mem_addr = {current_tag, current_index, current_bs, {WordBits{1'b0}}};
            next_state = READ_DATA;
        end
    end

    READ_DATA: begin
        if(cache_hit) begin
            read_cache = 1'b1;
            next_done = 1'b1;
        end

        next_state = IDLE;
    end
    endcase
end

endmodule
