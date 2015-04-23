

int STATENUMBER = 0;

void MainStateMachine( )
{
   switch(STATENUMBER)
   {
     case 0:
       PlayMode();
     break;
     case 1:
       Question1();
     break;
     case 2:
       Question2();
     break;
     default:
       PlayMode();
     break;
 
   } 
  
  
}

void PlayMode( )
{
  // the button should say quiz
  //everything should be displayed
  //sliders should be dynamic
}
void Question1()
{
  // the button should say continue
  //no graph
  //sliders are static
  //yes equation: 0.5sin(2x)
}
void Question2()
{
  // the button should say continue
  //yes graph
  //sliders are static
  // no equation displayed : 0.6cos(3x)
}

