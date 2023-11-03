module cache_tag_mem #(
    parameter IndexBits,
    parameter TagBits,
    parameter N
)(
    input logic clk,
    input logic rst,

    input logic [IndexBits-1:0] req_index,
    input logic req_we,

    input logic [TagBits-1:0] write_tag,
    input logic write_valid,

    input logic [TagBits-1:0] req_tag,
    output logic cache_hit
);

typedef struct packed {
    logic valid;
    logic [TagBits-1:0] tag;
} cache_tag_t;

cache_tag_t mem[N-1:0];

assign cache_hit = mem[req_index].tag == req_tag & mem[req_index].valid;

always @(posedge clk) begin
    if(rst) begin
        for(integer k = 0; k < N; k = k + 1) begin
            mem[k].valid = 1'b0;
        end
    end else if(req_we) begin
        mem[req_index] <= {write_valid, write_tag};
    end
end

endmodule

module cache_data_mem #(
    parameter Width = 64,
    parameter N = 256
) (
    input logic clk,
    input logic rst,

    input logic re,
    input logic[N-1:0] index,

    input logic we,
    input logic[Width-1:0] write_data,

    output logic[Width-1:0] read_data
);

reg [Width-1:0] mem [N-1:0];

always @ (posedge clk) begin
    if(rst) begin
        data <= 0;
    end else if(re) begin
        data <= mem[index];
    end else begin
        data <= 0;
    end
end

always @ (posedge clk) begin
    if(!rst && we) begin
        mem[write_index] <= write_data;
    end
end

endmodule

module cache #(
    parameter AddrBusWidth = 32,
    parameter CacheBusWidth = 32,
    parameter MemBusWidth = 32,
    parameter CacheLineWidth = 32,
    parameter N = 256 // number of cache blocks
) (
    input logic clk,
    input logic rst,

    // cpu interface
    input logic[AddrBusWidth-1:0] addr,
    output logic[CacheBusWidth-1:0] r_data,
    input logic[CacheBusWidth-1:0] w_data,
    input logic[(CacheBusWidth/8)-1:0] w_sel,
    input logic re,
    input logic we,
    output reg ready,
    output reg r_data_valid,

    // memory interface
    output reg [AddrBusWidth-1:0] mem_addr,
    input logic [MemBusWidth-1:0] mem_r_data,
    output logic [MemBusWidth-1:0] mem_w_data,
    output logic [(MemBusWidth/8)-1:0] mem_w_sel,
    output logic mem_re,
    output logic mem_we,
    input logic mem_ready,
    input logic mem_r_data_valid
);

if(CacheBusWidth != MemBusWidth)
    $error($sformatf("Illegal values for parameters CacheBusWidth (%0d) and MemBusWidth (%0d)", CacheBusWidth, MemBusWidth));

localparam WordBits = $clog2(CacheLineWidth) - 3;
localparam IndexBits = $clog2(N);
localparam TagBits = AddrBusWidth - IndexBits - BlockBits - WordBits;

typedef struct packed {
    logic [TagBits-1:0] tag;
    logic [IndexBits-1:0] index;
} tag_index_t;

wire tag_index_t addr_ti = '{
    tag: addr[AddrBusWidth-1:AddrBusWidth - TagBits],
    index: addr[(WordBits+BlockBits+IndexBits-1):(WordBits+BlockBits)]
};

typedef enum [1:0] {
    IDLE       = 'b00, // no memory access
    READ_MEM   = 'b01, // Main memory read in progress
    READ_DATA  = 'b10, // Data available from main memory read
    WRITE_WAIT = 'b11  // Wait for memory ready for read
} state_t;

reg read_cache;
reg write_cache;

tag_index_t current_ti, next_current_ti;

reg [IndexBits-1:0] write_index;
reg [BlockBits-1:0] write_bs;
reg [MemBusWidth-1:0] write_data;

reg valid_flag;
reg next_done;
wire cache_hit;

cache_tag_mem #(.TagBits(TagBits), .IndexBits(IndexBits), .N(N)) tag_mem (
    .clk(clk), .rst(rst),
    .req_index(addr_ti.index), .req_we(valid_flag),
    .write_tag(addr_ti.tag), .write_valid(valid_flag),
    .req_tag(addr_ti.tag), .cache_hit(cache_hit)
);

cache_data_mem #(.Width(CacheLineWidth), .N(N)) data_mem (
    .clk(clk), .rst(rst),
    .re(read_cache), .index(current_ti.index),
    .we(write_cache), .write_cache(write_data),
    .read_data(r_data)
);

always_ff @(posedge clk) begin
    if(rst) begin
        ready <= 1'b1;
    end if(ready) begin
        if(!next_done && re) begin
            ready <= 1'b0;
        end
    end if(next_done) begin
        ready <= 1'b1;
    end
end

state_t state, next_state;

always_ff @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        current_ti <= '0;
        done <= 1'b0;
        ready <= 1'b1;
    end else begin
        done <= next_done;
        state <= next_state;
        current_ti <= next_current_ti;
    end
end

always_comb begin
    next_state = state;
    next_done = 1'b0;

    next_current_ti = current_ti;

    read_cache = 1'b0;
    write_cache = 1'b0;
    write_index = 0;
    write_data = 0;
    write_bs = 0;

    valid_flag = 1'b0;

    mem_re = 1'b0;
    mem_we = 1'b0;
    mem_addr = '0;

    case(state)
    IDLE: begin
        if(re) begin
            if(cache_hit) begin
                read_cache = 1'b1;
                next_done = 1'b1;
            end else begin
                next_state = READ_MISS;
                next_current_ti = addr_ti;
                valid_flag = 1'b1;
            end
        end else if(we) begin
            if(cache_hit) begin
                write_cache = 1'b1;
                write_index = current_ti.index;
                write_bs = current_ti.bs;
                write_data = w_data;
                write_mask = w_sel;
            end

            mem_we = 1'b1;
            mem_addr = {current_ti.tag, current_ti.index, current_ti.bs, {WordBits{1'b0}}};
            mem_w_data = w_data;
            mem_w_sel = w_sel;
            next_state = WRITE_WAIT;
        end
    end

    READ_MISS: begin
        if(!mem_ready) begin
            mem_re = 1'b1;
            mem_addr = {current_ti.tag, current_ti.index, current_ti.bs, {WordBits{1'b0}}};
            next_state = READ_MEM;
        end
    end

    READ_MEM: begin
        if(mem_ready) begin
            write_cache = 1'b1;
            write_index = current_ti.index;
            write_bs = current_ti.bs;
            write_data = mem_r_data;
            write_mask = 4'b1111;

            mem_re = 1'b1;
            mem_addr = {current_ti.tag, current_ti.index, current_ti.bs, {WordBits{1'b0}}};
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

    WRITE_WAIT: begin
        if(mem_ready) begin
            next_state = IDLE;
        end
    end

    endcase
end

endmodule
