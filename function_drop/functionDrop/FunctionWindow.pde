
//Serial communication variables
import processing.serial.*;
int serialPort = 3;
Serial port;

float xByte;
float fByte;

float  py, py2;


//variables that should be shared between both codes
int functionNumber = 0;
float amplitude = 1; //has to be between 0 and 1
float frequency = 1;
boolean DRAWFUNCTION = true;

int pastFunctionNumber = 0;
float pastAmplitude = 1;
float pastFrequency = 1;

char[] SendBuffer = new char[4];

//to be called at the end
void setupFunctionWindow()
{
  port = new Serial(this, Serial.list()[serialPort], 9600);  //
  // A serialEvent() is generated when a newline character is received :
  port.bufferUntil('\n');
}


void drawFunctionWindow(  )
{
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
    //py = functionWindowHeight/2+(functionWindowHeight/2)*amplitude*sin((2*PI*frequency*2/functionWindowWidth)*x);
    for (int i = 0; i< functionWindowWidth; i++)
    {
      //px2 = width/8 + cos(radians(angle2))*(radius);
      switch(functionNumber)
      {
        case 0:
          py2 = 0;
        break;
        case 1: // sine
          py2 = functionWindowHeight/2+(functionWindowHeight/2)*amplitude* sin((2*PI*frequency*2/functionWindowWidth)*i);
        break;
        case 2: //cos
          py2 = functionWindowHeight/2+(functionWindowHeight/2)*amplitude* cos((2*PI*frequency*2/functionWindowWidth)*i);
        break;
        case 3: //-x
          //py2 = functionWindowHeight-(i*functionWindowHeight*amplitude/functionWindowWidth);//functionWindowHeight/2-(functionWindowHeight/2)*amplitude*(i/functionWindowWidth-1);
          py2 = functionWindowHeight/2 - 2*(functionWindowHeight*amplitude/functionWindowWidth) * (i - functionWindowWidth/2);
        break;
        default:
          py2 = 0;
        break;
      }
        strokeWeight(3);
        if (py2 > functionWindowHeight)
        {
          py2 = functionWindowHeight;
        }
        else if (py2 < 0)
        {
          py2 = 0;
        }
        point(i+padding, (functionWindowHeight-py2)+padding);
     }
    line(width/2, padding, width/2, functionWindowHeight+padding);
    line(padding, functionWindowHeight/2+padding, width - padding, functionWindowHeight/2+padding);
    stroke(127,34,255);     //stroke color
    ellipse(xByte+padding, padding+functionWindowHeight-fByte, 5, 5); 
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
    
    fByte = map(fByte, -1000, 1000, 0, functionWindowHeight); //map to the screen height.
    xByte = map(xByte, -500, 500, 0, functionWindowWidth); //map to the screen width.
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

