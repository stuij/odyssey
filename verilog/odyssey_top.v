module odyssey_top
  (
   input wire        clk_25mhz,
   input wire [6:0]  btn,
   output wire [7:0] led,
   
   output wire       wifi_en,
   output wire       wifi_gpio0,
   
   output wire       oled_csn,
   output wire       oled_clk,
   output wire       oled_mosi,
   output wire       oled_dc,
   output wire       oled_resn,

   output wire       usb_fpga_pu_dp, usb_fpga_pu_dn,
   input wire        usb_fpga_bd_dp, usb_fpga_bd_dn,
   );
   assign wifi_en = 1;
   assign wifi_gpio0 = btn[0];

   wire             resetq = btn[0];
   localparam       MHZ = 25;
   
   // clock generator
   localparam       c_clk_pixel_mhz = 25;
   localparam       c_clk_spi_mhz = 4*c_clk_pixel_mhz; // *4 or more
   
   wire             clk_locked;
   wire [3:0]       clocks;
   ecp5pll
     #(
       .in_hz( 25*1000000),
       .out0_hz( c_clk_spi_mhz*1000000),
       .out1_hz( c_clk_pixel_mhz*1000000)
       )
   ecp5pll_inst
     (
      .clk_i(clk_25mhz),
      .clk_o(clocks),
      .locked(clk_locked)
      );
   wire           clk_lcd = clocks[0];
   wire           clk_pixel = clocks[1];

   // === keyboard ==============
   // enable pull ups on both D+ and D-
   assign usb_fpga_pu_dp = 1'b1;
   assign usb_fpga_pu_dn = 1'b1;

   wire           ps2clk  = usb_fpga_bd_dp;
   wire           ps2data = usb_fpga_bd_dn;

   ps2kbd kbd(clk_25mhz, ps2clk, ps2data, led, , );

   // === display ===============
   
   wire           S_reset = ~btn[0];
   
   wire           vga_hsync;
   wire           vga_vsync;
   wire           vga_blank;
   wire           vga_disp;
   wire [12:0]    x_pos;
   wire [8:0]     y_pos;
   wire [7:0]     vga_r, vga_g, vga_b;
   vga
     #(
       .c_resolution_x(240),
       .c_hsync_front_porch(1800),
       .c_hsync_pulse(1),
       .c_hsync_back_porch(1800),
       .c_resolution_y(240),
       .c_vsync_front_porch(1),
       .c_vsync_pulse(1),
       .c_vsync_back_porch(1),
       .c_bits_x(12),
       .c_bits_y(8)
       )
   vga_instance
     (
      .clk_pixel(clk_pixel),
      .clk_pixel_ena(1'b1),
      .test_picture(1'b1),
      .beam_x(x_pos),
      .beam_y(y_pos),
      .vga_hsync(vga_hsync),
      .vga_vsync(vga_vsync),
      .vga_blank(vga_blank),
      .vga_de(vga_disp)
      );
   
   lcd_video
     #(
       .c_clk_spi_mhz(c_clk_spi_mhz),
       .c_vga_sync(1),
       .c_reset_us(1000),
       //.c_init_file("st7789_linit_long.mem"),
       //.c_init_size(75), // long init
       //.c_init_size(35), // standard init (not long)
       .c_clk_phase(0),
       .c_clk_polarity(1),
       .c_x_size(240),
       .c_y_size(240),
       .c_color_bits(16)
       )
   lcd_video_instance
     (
      .reset(S_reset),
      .clk_pixel(clk_pixel), // 25 MHz
      .clk_pixel_ena(1),
      .clk_spi(clk_lcd), // 100 MHz
      .clk_spi_ena(1),
      .blank(vga_blank),
      .hsync(vga_hsync),
      .vsync(vga_vsync),
      .color(vga_rgb),
      .spi_resn(oled_resn),
      .spi_clk(oled_clk),
      //.spi_csn(oled_csn), // 8-pin ST7789
      .spi_dc(oled_dc),
      .spi_mosi(oled_mosi)
      );
   assign oled_csn = 1; // 7-pin ST7789
   
   reg [7:0]      R_vga_r; reg [7:0] R_vga_g; reg [7:0] R_vga_b;
   
   always @(posedge clk_pixel) begin
      
      if(vga_blank == 1'b1) begin
         // analog VGA needs this, DVI doesn't
         R_vga_r <= {8{1'b0}};
         R_vga_b <= {8{1'b0}};
         R_vga_g <= {8{1'b0}};
      end
      else begin
         R_vga_r <= {8{1'b0}};
         R_vga_b <= y_pos == 0 || y_pos == 239 || x_pos == 0 || x_pos == 239 ? {8{1'b11111111}} : {8{1'b0}};
         R_vga_g <= y_pos == 1 || y_pos == 240 || x_pos == 1 || x_pos == 240 ? {8{1'b11111111}} : {8{1'b0}};
      end
   end
   
   wire [15:0]  vga_rgb = {R_vga_r[7:3],R_vga_g[7:2],R_vga_b[7:3]};
   
endmodule
