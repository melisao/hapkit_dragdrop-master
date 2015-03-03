class Function {
  color c;
  float xpos;
  float ypos;
  String math_string = "";
  float fn_height = 20;
  float fn_width = 20;
  
  Function(userc, userx, usery, usermath) {
    c = userc;
    xpos = userx;
    ypos = usery;
    math_string = usermath;
  }
  
  update_pos(ux, uy) {
    xpos = ux;
    ypos = uy;
  }
  
  draw_fn(ux, uy) {
    rect(ux, uy, fn_height, fn_width);
  }
  
}
