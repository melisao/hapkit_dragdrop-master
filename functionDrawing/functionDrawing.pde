
import processing.serial.*;
Serial port;
boolean isA = true;

float xByte;
float fByte;

float px, py, px2, py2;
float angle, angle2;
float radius = 50;
float amplitude = 0;
float frequency = 2;
float frequency2 = 2;
float x, x2;

// used to create font
PFont myFont;

void setup(){
  size(600, 400);
  background (127);
  println("width = ", width);
  println("height = ", height);
  // List all the available serial ports
  //println(Serial.list());
  port = new Serial(this, Serial.list()[5], 9600);  //
  // A serialEvent() is generated when a newline character is received :
  port.bufferUntil('\n');
  background(0);      // set inital background:
  // generate processing font from system font
  myFont = createFont("verdana", 12);
  textFont(myFont);
}

void draw(){
  background (127);
  noStroke();
  fill(255);
  //ellipse(width/8, 75, radius*2, radius*2);
  // rotates rectangle around circle
  
  py = height/2+(height/2)*sin(radians(angle));
  //rectMode(CENTER);
  fill(0);
  stroke(200);

  // keep reinitializing to 0, to avoid
  // flashing during redrawing
  angle2 = 0;
  //amplitude = height*20*0.09;
  // draw static curve - y = sin(x)
  for (int i = 0; i< width; i++){
    //px2 = width/8 + cos(radians(angle2))*(radius);
    py2 = height/2+(height/2)* sin(radians(angle2));
    point(width/8+radius+i, py2);
    angle2 -= frequency2;
  }

  // send small ellipse along sine curve
  // to illustrate relationship of circle to wave
  noStroke();
  ellipse(width/8+radius+x, py, 5, 5);
  angle -= frequency;
  x+=1;

  // when little ellipse reaches end of window
  // reinitialize some variables
  if (x>= width-60) {
    x = 0;
    angle = 0;
  }
  
  stroke(127,34,255);     //stroke color
  //point(width-xByte, fByte);
  ellipse(width-xByte, fByte, 5, 5);

  // draw dynamic line connecting circular
  // path with wave
  //stroke(50);
  //line(px, py, width/8+radius+x, py);

  // output some calculations
  
  text("py = " + py, 215, 185);
}

void serialEvent (Serial port) {
  // get the ASCII string:
  String inString = port.readStringUntil('\n');
  if (inString != null) {
    String[] list = split(inString, ',');
    
    String xString = trim(list[0]);                // trim off whitespaces.
    xByte = float(xString);           // convert to a number.
    String fString = trim(list[1]);
    fByte = float(fString);
    
    fByte = map(fByte, -1000, 1000, 0, height); //map to the screen height.
    xByte = map(xByte, -500, 500, 0, width); //map to the screen width.
    //println("after: ", xByte, fByte);
  } 
 }

