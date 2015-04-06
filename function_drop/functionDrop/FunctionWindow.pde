

//variables that should be shared between both codes
float amplitude = 1;
float frequency = 3;
int functionNumber = 0;

//to be called at the end
void setupFunctionWindow( void )
{
  port = new Serial(this, Serial.list()[5], 9600);  //
  // A serialEvent() is generated when a newline character is received :
  port.bufferUntil('\n');
}


void drawFunctionWindow( void )
{
  
  py = functionWindowHeight/2+(functionWindowHeight/2)*amplitude*sin((2*PI*frequency*2/functionWindowWidth)*x);
  for (int i = 0; i< functionWindowWidth; i++){
    //px2 = width/8 + cos(radians(angle2))*(radius);
    switch(functionNumber)
    {
      case 0:
        py2 = 0;
      break;
      case 1:
      py2 = functionWindowHeight/2+(functionWindowHeight/2)*amplitude* sin((2*PI*frequency*2/functionWindowWidth)*i);
      break;
      default:
        py2 = 0;
      break;
    }
    point(i, py2);
    }
  }
}
