module dm11a88 (
    input  wire  clk_50m,
    output logic vcc,
    output logic gnd,
    output logic di,
    output logic clk,
    output logic lat
);
  parameter LENGTH = 15;
  parameter DATA_LEN = 2;
  logic [DATA_LEN-1:0][LENGTH:0] data;
  logic [10:0] dnt;
  assign data = '{'b11111111_11111110, 'b11111111_01111111};
  assign vcc = 1;
  assign gnd = 0;
  logic [ 1:0] cnt;
  logic [ 1:0] ready;
  logic [ 3:0] index;
  logic [25:0] wait_sec;

  always_ff @(posedge clk_50m) begin
    case (ready)
      0: begin
        wait_sec <= wait_sec + 1 % 10000;
        if (!wait_sec) begin
          ready <= 1;
          lat   <= 0;
        end
      end
      1: begin
        cnt <= cnt + 1;
        if (cnt == 3) begin
          index <= index + 1;
          cnt   <= 0;
          if (index == LENGTH) begin
            ready <= 2;
            cnt   <= 0;
            index <= 0;
          end
        end
      end
      2: begin
        ready <= 0;
        lat   <= 1;
        dnt   <= (dnt + 1) % DATA_LEN;
      end
      default: begin
      end
    endcase
  end

  always_latch
    case (cnt)
      0: clk <= 0;
      1: begin
        case (dnt)
          default: di <= data[dnt][index];
          -1: di <= data[-1][index];
        endcase
      end
      2: clk <= 1;
      default: begin
      end
    endcase

endmodule
