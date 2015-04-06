// Code based on http://stackoverflow.com/a/15306450

FnCollection fnblocks;
DropTarget droptarget;
float textSize;
int padding = 20;
int functionWindowHeight;
int functionWindowWidth;



void setup() {
  size(800, 1000);
  textSize = 20; 
  textFont(createFont("Times New Roman", textSize));
  // Create function strings
  String[] textValues = new String[] {
    "f(x) = x + 1", "f(x) = x + 2"
  };
  // Create collection for FnBlocks
  fnblocks = new FnCollection(textValues);
  droptarget = new DropTarget(10, height - (height/4)); // Change this later 
  // Do not loop! only update when events warrant,
  // based on redraw() calls  
  //noLoop();
  setupFunctionWindow();
}
// fall through drawing
void draw() 
{ 
  drawbg(); 
  drawFunctionWindow();
  droptarget.draw(); 
  fnblocks.draw();
}// canvas.draw();}

// fall through event handling
void mouseMoved() { 
  fnblocks.mouseMoved(mouseX, mouseY); 
  redraw();
}
void mousePressed() { 
  fnblocks.mousePressed(mouseX, mouseY); 
  redraw();
}
void mouseDragged() { 
  fnblocks.mouseDragged(mouseX, mouseY); 
  redraw();
}
void mouseReleased() { 
  fnblocks.mouseReleased(mouseX, mouseY); 
  redraw();
}

void drawbg() {
  background(255);
  fill(255);
  functionWindowHeight = height - (height/4 + 2*padding);
  functionWindowWidth = width - 2*padding;
  rect(padding, padding, functionWindowWidth, functionWindowHeight); // Draw the rectangle for the canvas
}

/**
 * A collection of function blocks. This is *only* a collecton,
 * it is simply responsible for passing along events.
 */
class FnCollection {
  FnBlock[] fnblocks;

  // construct
  FnCollection(String[] strings) {
    fnblocks = new FnBlock[strings.length];
    int x, y;
    for (int i=0, last=strings.length; i<last; i++) {
      x = (int) random(padding, width - padding);
      y = (int) random(height - (height/4 + padding), height - padding);
      fnblocks[i] = new FnBlock(strings[i], x, y, color(random(255)), 1, 3, 1);
    }
  }

  // fall through drawing   
  void draw() {

    // since we don't care about counting elements
    // in our fnblock container, we use the "foreach"
    // version of the for loop. This is identical to
    // "for(int i=0; i<fnblocks.size(); i++) {
    //    FnBlock f = fnblocks[i];
    //    [... use f here ...]
    //  }"
    // except we don't have to unpack our list manually.

    for (FnBlock f : fnblocks) { 
      f.draw();
    }
  }

  // fall through event handling
  void mouseMoved(int mx, int my) { 
    for (FnBlock f : fnblocks) { 
      f.mouseMoved(mx, my);
    }
  } 
  void mousePressed(int mx, int my) { 
    for (FnBlock f : fnblocks) { 
      f.mousePressed(mx, my);
    }
  } 
  void mouseDragged(int mx, int my) { 
    for (FnBlock f : fnblocks) { 
      f.mouseDragged(mx, my);
    }
  }
  void mouseReleased(int mx, int my) { 
    for (FnBlock f : fnblocks) { 
      f.mouseReleased(mx, my);
    }
  }
}

/**
 * Individual FnBlocks
 */
class FnBlock {
  String s;
  float x, y, w, h;
  boolean active;
  color baseColor = 0;
  color fillColor = 0;
  int cx, cy, ox=0, oy=0;

  // These variables will determine what function is drawn to the screen
  float myAmplitude = 0;
  float myFrequency = 0;
  int myFunctionNumber = 0;

  public FnBlock(String _s, int _x, int _y, color _c, int myFunctionNumber_, float myAmplitude_, float myFrequency_) {    
    s = _s;
    x = _x;
    y = _y;
    w = textWidth(s);
    h = textSize;
    //fillColor = _c;
    myFunctionNumber = myFunctionNumber_;
    myAmplitude = myAmplitude_;
    myFrequency = myFrequency_;
  }

  void draw() {
    fill(fillColor);
    text(s, ox+x, oy+y+h);
  }

  boolean over(int mx, int my) {
    return (x <= mx && mx <= x+w && y <= my && my <= y+h);
  }

  // Mouse moved: is the cursor over this FnBlock?
  // if so, change the fill color
  void mouseMoved(int mx, int my) {
    active = over(mx, my);
    fillColor = (active ? color(155, 155, 0) : baseColor);
  }

  // Mouse pressed: are we active? then
  // mark where we started clicking, so 
  // we can do offset computation on
  // mouse dragging.
  void mousePressed(int mx, int my) {
    if (active) {
      cx = mx;
      cy = my;
      ox = 0;
      oy = 0;
    }
  }

  // Mouse click-dragged: if we're active,
  // change the draw offset, based on the
  // distance between where we initially
  // clicked, and where the mouse is now.
  void mouseDragged(int mx, int my) {
    if (active) {
      ox = mx-cx;
      oy = my-cy;
    }
  }

  // Mouse released: if we're active,
  // commit the offset to this FnBlock's
  // position. Also, regardless of
  // whether we're active, now we're not.  
  void mouseReleased(int mx, int my) {
    if (active) {
      x += mx-cx;
      y += my-cy;
      ox = 0;
      oy = 0;
      dropTargetCheck();
    }
    active = false;
  }

  void dropTargetCheck() {
    // If the fnblock is on top of the drop target, print the name of the function to the console.
    // Later replace this with an actual function call.
    if (droptarget.x-padding <= x && x <= droptarget.x+droptarget.w && droptarget.y <= y+padding && y <= droptarget.y+droptarget.h) {
      //println(s);
      if (droptarget.dropfn(this) == true) {
        println("Drop successful.");
        baseColor = color(255, 0, 0);
        draw();
      } else {
        println("Target full.");
      }
    } else {
      if (droptarget.removefn(this) == true) {
        println("Removed function.");
        baseColor = 0;
        draw();
      } else {
        println("Function not removed.");
      }
    }
  }
}

class DropTarget {
  float x, y, w, h;
  boolean dtempty = true;
  color fillColor = color(200);
  FnBlock curFn;

  public DropTarget(int _x, int _y) {
    x = _x;
    y = _y;
    w = 200;
    h = textSize;
  }

  void draw() {
    fill(fillColor);
    stroke(153);
    rect(x, y, w, h);
  }

  boolean empty() {
    return dtempty;
  }

  boolean dropfn(FnBlock fnblock) {
    // Attempting to drop a block on the target will return true if 
    // successful. Otherwise it will return false.
    if (dtempty) {
      curFn = fnblock;
      print("Calling function from FnBlock: ");
      
      functionNumber = fnblock.myFunctionNumber;
      amplitude = fnblock.myAmplitude;
      frequency = fnblock.myFrequency;
      
      //println(fnblock.s); // Placeholder for function call
      dtempty = false;
      return true;
    } else {
      return false;
    }
  }

  boolean removefn(FnBlock fnblock) {
    // Remove a block from the drop target.
    if (curFn == fnblock) {
      curFn = null;
      dtempty = true;
      functionNumber = 0;
      amplitude = 0;
      frequency = 0;
      return true;
    } else {
      return false;
    }
  }
}

