// Drag and Drop Code based on http://stackoverflow.com/a/15306450
import java.util.Map;
import controlP5.*;

FnCollection fnblocks;
DropTarget droptarget;
ControlP5 cp5;

float textSize;
int padding = 20;
int functionWindowHeight;
int functionWindowWidth;

void setup() {
  size(800, 800);
  textSize = 20; 
  textFont(createFont("Times New Roman", textSize));

  droptarget = new DropTarget(padding, height - (height/4)); 

  // Create ControlP5 object for the amplitude and frequency sliders
  cp5 = new ControlP5(this);
  setupGUI();

  // Create function strings
  String[] textValues = new String[] {
    "f(x) = sin(x)", "f(x) = 2sin(0.5x)"
  };

  // Create collection for FnBlocks
  fnblocks = new FnCollection();

  // Add FnBlocks to FnCollection
  // Add more functions here!
  fnblocks.updateBlock(1, "sin", 1, 1,true);
  fnblocks.updateBlock(2, "cos", 1, 1,true);
  fnblocks.updateBlock(3, "-x",  1, 1,false);

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
  MainStateMachine();
}

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
  HashMap<Integer, FnBlock> fnblocks;
  public boolean hide = false;

  // construct 
  FnCollection() {
    fnblocks = new HashMap<Integer, FnBlock>();
  }

  void updateBlock(int myFunctionNumber_, String s_, float myAmplitude_, float myFrequency_, boolean myHasFrequency_) {
    FnBlock temp_block;
    if (fnblocks.containsKey(myFunctionNumber_)) {
      temp_block = fnblocks.get(myFunctionNumber_);
      temp_block.myAmplitude = myAmplitude_;
      temp_block.myFrequency = myFrequency_;
      temp_block.base_string = s_;
      temp_block.myHasFrequency = myHasFrequency_;
    } else {
      int x = (int) random(padding, width - padding);
      int y = (int) random(height - (height/4 + padding), height - padding);
      temp_block = new FnBlock(s_, x, y, color(random(255)), myFunctionNumber_, myAmplitude_, myFrequency_, myHasFrequency_);
    }
    fnblocks.put(myFunctionNumber_, temp_block);
  }
  
  FnBlock getFn(int fnNumber) {
    if (fnblocks.containsKey(fnNumber)) {
      return (fnblocks.get(fnNumber));
    } else {
      return null;
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

    if (!this.hide) {
      for (FnBlock f : fnblocks.values ()) {
        f.draw();
      }
    }
  }

  // fall through event handling
  void mouseMoved(int mx, int my) { 
    for (FnBlock f : fnblocks.values ()) { 
      f.mouseMoved(mx, my);
    }
  } 
  void mousePressed(int mx, int my) { 
    for (FnBlock f : fnblocks.values ()) { 
      f.mousePressed(mx, my);
    }
  } 
  void mouseDragged(int mx, int my) { 
    for (FnBlock f : fnblocks.values ()) { 
      f.mouseDragged(mx, my);
    }
  }
  void mouseReleased(int mx, int my) { 
    for (FnBlock f : fnblocks.values ()) { 
      f.mouseReleased(mx, my);
    }
  }
}

/**
 * Individual FnBlocks
 */
class FnBlock {
  String base_string;
  float x, y, w, h;
  boolean active;
  color baseColor = 0;
  color fillColor = 0;
  int cx, cy, ox=0, oy=0;

  // These variables will determine what function is drawn to the screen
  float myAmplitude = 0;
  float myFrequency = 0;
  int myFunctionNumber = 0;
  boolean myHasFrequency = false;

  public FnBlock(String s_, int x_, int y_, color c_, int myFunctionNumber_, float myAmplitude_, float myFrequency_, boolean myHasFrequency_) {    
    base_string = s_;
    String s;
    if (myHasFrequency_ == true )
    {
      s = "f(x) = " + myAmplitude + "(" + base_string + "(" + myFrequency + "x))";
    }
    else
    {
      s = "f(x) = " + myAmplitude + "(" + base_string + ")";
    }
    x = x_;
    y = y_;
    w = textWidth(s);
    h = textSize;
    //fillColor = _c;
    myFunctionNumber = myFunctionNumber_;
    myAmplitude = myAmplitude_;
    myFrequency = myFrequency_;
    myHasFrequency = myHasFrequency_;
  }
  
  void randomLocation() {
    x = (int) random(padding, width - padding);
    y = (int) random(height - (height/4 + padding), height - padding);
  }

  void draw() {
    String ramp = String.format("%.2f", myAmplitude);
    String rfreq = String.format("%.2f", myFrequency);
    String s;
    if (myHasFrequency == true )
    {
      s = "f(x) = " + ramp + "(" + base_string + "(" + rfreq + "x))";
    }
    else
    {
      s = "f(x) = " + myAmplitude + "(" + base_string + ")";
    }
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
    // If this function block is dropped on top of the target and the target is empty, add it to the droptarget.
    if (droptarget.x-padding <= x && x <= droptarget.x+droptarget.w && droptarget.y <= y+padding && y <= droptarget.y+droptarget.h) {
      if (droptarget.dropfn(this) == true) {
        println("Drop successful.");
        baseColor = color(255, 0, 0);
        draw();
      } else {
        // If there is already a function in there, do nothing. 
        println("Target full.");
      }
    } else {
      // If this function block was dropped outside of the droptarget and it was previously in there, 
      // remove it.
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

  public DropTarget(int x_, int y_) {
    x = x_;
    y = y_;
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

      draw_function(fnblock);

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

  boolean removeCurFn() {
    // Remove the current function block (if any)
    if (!this.empty()) {
      curFn.randomLocation();
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

void setupGUI() {
  // Create horizontal amplitude slider
  // The value of this slider will be linked to the sliderAmp function
  cp5.addSlider("sliderAmp")
    .setPosition(droptarget.x + droptarget.w + padding, droptarget.y)
      .setRange(-1, 1)
        ;
  cp5.getController("sliderAmp").getCaptionLabel().setText("Amplitude").setColor(0);

  // Create horizontal frequency slider
  // The value of this slider will be linked to the sliderFreq function 
  cp5.addSlider("sliderFreq")
    .setPosition(droptarget.x + droptarget.w + padding, droptarget.y + padding)
      .setRange(0, 3)
        ;
  cp5.getController("sliderFreq").getCaptionLabel().setText("Frequency").setColor(0);

  // create a new button with name 'Quiz'
  cp5.addButton("startQuiz")
    .setValue(0)
      .setPosition(width - 150, height - 50)
        .setSize(100, 20)
          ;
}

void sliderAmp(float slider_amp) {
  // Update the current function block with a new amplitude
  println("Slider amp is " + slider_amp);

  if (!droptarget.empty()) {
    droptarget.curFn.myAmplitude = slider_amp;
  }
  draw_function(droptarget.curFn);
}

void sliderFreq(float slider_freq) {
  // Update the current function block with a new frequency
  println("Slider amp is " + slider_freq);

  if (!droptarget.empty()) {
    droptarget.curFn.myFrequency = slider_freq;
  }
  draw_function(droptarget.curFn);
}

void draw_function(FnBlock fblock) {
  // Update the global function parameters
  functionNumber = fblock.myFunctionNumber;
  amplitude = fblock.myAmplitude;
  frequency = fblock.myFrequency;
}

public void startQuiz(int buttonValue) {
  println("a button event from startQuiz: "+buttonValue);
  float tempVal = buttonValue;
  STATENUMBER = (int)tempVal;
  if (tempVal >= 2) {
    tempVal = 0;
  } else {
    tempVal += 1;
  }
  println(cp5.getController("startQuiz").getValue());
  // If the button is set to broadcast, setting the value will trigger an event.
  // This cause the button to go into an infinite loop. To prevent this, disable
  // broadcast, set the value, and re-enable broadcast.
  cp5.getController("startQuiz").setBroadcast(false);
  cp5.getController("startQuiz").setValue(tempVal);
  cp5.getController("startQuiz").setBroadcast(true);
}

