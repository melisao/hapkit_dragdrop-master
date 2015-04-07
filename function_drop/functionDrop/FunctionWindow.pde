
//Serial communication variables
import processing.serial.*;
Serial port;

float xByte;
float fByte;

float  py, py2;


//variables that should be shared between both codes
float amplitude = 1; //has to be between 0 and 1
float frequency = 3;
int functionNumber = 0;

//to be called at the end
void setupFunctionWindow()
{
  port = new Serial(this, Serial.list()[5], 9600);  //
  // A serialEvent() is generated when a newline character is received :
  port.bufferUntil('\n');
}


void drawFunctionWindow(  )
{
  
  //py = functionWindowHeight/2+(functionWindowHeight/2)*amplitude*sin((2*PI*frequency*2/functionWindowWidth)*x);
  for (int i = padding; i< functionWindowWidth+padding; i++)
  {
    //px2 = width/8 + cos(radians(angle2))*(radius);
    switch(functionNumber)
    {
      case 0:
        py2 = 0;
      break;
      case 1:
        py2 = padding+functionWindowHeight/2+(functionWindowHeight/2)*amplitude* sin((2*PI*frequency*2/functionWindowWidth)*i);
      break;
      default:
        py2 = 0;
      break;
      }
      strokeWeight(3);
      point(i, py2);
   }
  line(width/2, padding, width/2, functionWindowHeight+padding);
  line(padding, functionWindowHeight/2+padding, width - padding, functionWindowHeight/2+padding);
  stroke(127,34,255);     //stroke color
  ellipse(functionWindowWidth-xByte, padding+functionWindowHeight-fByte, 5, 5); 
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
    
    fByte = map(fByte, -1000, 1000, 0, functionWindowHeight); //map to the screen height.
    xByte = map(xByte, -500, 500, 0, functionWindowWidth); //map to the screen width.
    println("after: ", xByte, fByte);
  } 
 }



