
//Serial communication variables
import processing.serial.*;
int serialPort = 3; //set this variable to be the serial Port that your HAPKIT is connected to
Serial port;

float xByte;
float fByte;

float  py, py2;


//variables that should be shared between both codes
int functionNumber = 0;
float amplitude = 0; //has to be between 0 and 1
float frequency = 0;
boolean DRAWFUNCTION = true;
boolean TRACEFUNCTION = true;

int pastFunctionNumber = 0;
float pastAmplitude = 0;
float pastFrequency = 0;

int radius = 0;
float unitCircleCenterX = 0;
float unitCircleCenterY = 0;

char[] SendBuffer = new char[4];

//to be called at the end
void setupFunctionWindow()
{
  port = new Serial(this, Serial.list()[serialPort], 9600);  //
  // A serialEvent() is generated when a newline character is received :
  port.bufferUntil('\n');
}

void setupUnitCircleWindow()
{
  radius = unitCircleWindowWidth/2-padding;
  unitCircleCenterX = unitCircleWindowX + unitCircleWindowWidth/2;
  unitCircleCenterY = unitCircleWindowY + unitCircleWindowHeight/2;
}


void drawFunctionWindow(  )
{
  float f_WindowWidth = functionWindowWidth;
  float f_WindowHeight = functionWindowHeight;
  if ((functionNumber != pastFunctionNumber) || 
    (amplitude != pastAmplitude) ||
    (frequency != pastFrequency))
  {
    sendNewValues();
    pastFunctionNumber = functionNumber;
    pastAmplitude = amplitude;
    pastFrequency = frequency;
  }
  if (DRAWFUNCTION == true)
  {
    stroke(127, 34, 255);     //stroke color
    //draw ellipse:
    //ellipse(20, 20, radius*amplitude*2, radius*amplitude*2);
    float circleRadius = radius*amplitude;
    float px = 0;
    float py = 0;
    float angle = 0;
    ellipse(unitCircleCenterX, unitCircleCenterY, circleRadius*2, circleRadius*2);
    //py = functionWindowHeight/2+(functionWindowHeight/2)*amplitude*sin((2*PI*frequency*2/functionWindowWidth)*x);
    for (int i = - (functionWindowWidth/2); i< (functionWindowWidth/2); i++)
    {
      //px2 = width/8 + cos(radians(angle2))*(radius);
      switch(functionNumber)
      {
      case 0:
        py2 = 0;
        break;
      case 1: // sine
        py2 = (f_WindowHeight/2) * amplitude*sin((2*PI*frequency*2/f_WindowWidth)*i);
        break;
      case 2: //cos
        py2 = (f_WindowHeight/2) * amplitude*cos((2*PI*frequency*2/f_WindowWidth)*i);
        break;
      case 3: //-x
        py2 =  (-f_WindowHeight/f_WindowWidth) *amplitude* float(i);
        break;
      default:
        py2 = 0;
        break;
      }
      strokeWeight(3);
      if (py2 > functionWindowHeight/2)
      {
        py2 = functionWindowHeight/2;
      } else if (py2 < (-functionWindowHeight/2))
      {
        py2 = -functionWindowHeight/2;
      }
      if (functionNumber != 0 && TRACEFUNCTION == true) {
        point(i+padding+functionWindowWidth/2, -py2+padding+functionWindowHeight/2);
      }
    }

    stroke(127, 34, 255);     //stroke color
    angle = (2*PI*frequency*2/f_WindowWidth)*xByte;
    String fixed_angle = String.format("%.2f", (2*PI*2/f_WindowWidth)*xByte);
    px = circleRadius*cos(angle);
    py = -circleRadius*sin(angle);
    String fixed_y = String.format("%.2f", (2 * fByte)/functionWindowHeight);
    
    if (TRACEFUNCTION == true) {
      stroke(255, 34, 255);     //stroke color purplish
      ellipse(xByte+padding+functionWindowWidth/2, padding+functionWindowHeight/2, 5, 5);
      stroke(127, 34, 255);     //stroke color reddish
      ellipse(xByte+padding+functionWindowWidth/2, padding+functionWindowHeight/2-fByte, 5, 5);
      fill(0);
      text("("+fixed_angle+", "+fixed_y+")", xByte+padding*2+functionWindowWidth/2, padding+functionWindowHeight/2-fByte);
      fill(255);
    } else {
      stroke(255, 34, 255);     //stroke color reddish
      ellipse(xByte+padding+functionWindowWidth/2, padding+functionWindowHeight/2, 5, 5);
      stroke(127, 34, 255);     //stroke color purplish
    }
    ellipse(unitCircleCenterX+px, unitCircleCenterY+py, 5, 5);
  }
}


void serialEvent (Serial port) {
  // get the ASCII string:
  String inString = port.readStringUntil('\n');
  //println("got serial event! \n");
  if (inString != null) 
  {
    String[] list = split(inString, ',');

    String xString = trim(list[0]);                // trim off whitespaces.
    xByte = float(xString);           // convert to a number.
    String fString = trim(list[1]);
    fByte = float(fString);
    //println("before: ", xByte, fByte);
    fByte = map(fByte, -1000, 1000, 0, functionWindowHeight); //map to the screen height.
    xByte = map(xByte, -500, 500, 0, functionWindowWidth); //map to the screen width.
    fByte = fByte -functionWindowHeight/2;
    xByte = xByte - functionWindowWidth/2;
    //println("after: ", xByte, fByte);
  }
}

void sendNewValues()
{
  SendBuffer[0] = (char)functionNumber;//(char)functionNumber;
  SendBuffer[1] = (char)(amplitude*100);
  SendBuffer[2] = (char)(frequency * 10);
  SendBuffer[3] = 255;
  port.write(SendBuffer[0]);
  port.write(SendBuffer[1]);
  port.write(SendBuffer[2]);
  port.write(SendBuffer[3]);
  //println(SendBuffer[0],SendBuffer[1],SendBuffer[2],SendBuffer[3]);
}

