// Written by Richard Davis

float bx;
float by;
int bs = 20;
boolean bover = false;
boolean locked = false;
float bdifx = 0.0; 
float bdify = 0.0; 
int num_fns = 3;

// Create an array of num_fns FunctionBlocks 
FunctionBlock[] fblocks = new FunctionBlock[num_fns];
FunctionBlock testfn = new FunctionBlock(color(2), 20, 20, "x");

void setup() 
{
  size(640, 480);
  bx = width/2.0;
  by = height/2.0;
  rectMode(RADIUS);  

  // Initialize each FunctionBlock using a for loop.
  for (int i = 0; i < num_fns; i ++ ) { 
    fblocks[i] = new FunctionBlock(color(random(255), random(255), random(255)), bx + (i * 20), by + (i * 20), "x");
  }
}

void draw() 
{ 
  background(0);
  
  // Initialize each FunctionBlock using a for loop.
  for (int i = 0; i < num_fns; i ++ ) { 
    
    int w = fblocks[i].get_width();
    int h = fblocks[i].get_height();
    float curx = fblocks[i].get_xpos();
    float cury = fblocks[i].get_ypos();
    
    // Test if the cursor is over the box 
    if (mouseX > curx-w && mouseX < curx+w && 
      mouseY > cury-h && mouseY < cury+h) {
      bover = true;  
      if (!locked) { 
        stroke(255); 
        fill(153);
      }
    } else {
      stroke(153);
      fill(153);
      bover = false;
    }
  
    // Draw the box
    fblocks[i].update_pos(bx, by);
    fblocks[i].drawfn();
  }
}

void mousePressed() {
  if (bover) { 
    locked = true; 
    fill(255, 255, 255);
  } else {
    locked = false;
  }
  bdifx = mouseX-bx; 
  bdify = mouseY-by;
}

void mouseDragged() {
  if (locked) {
    bx = mouseX-bdifx; 
    by = mouseY-bdify;
  }
}

void mouseReleased() {
  locked = false;
}

