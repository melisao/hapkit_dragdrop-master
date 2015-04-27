int STATENUMBER = 0;
int PREVSTATENUMBER = 0;

void MainStateMachine( )
{
  if (PREVSTATENUMBER != STATENUMBER) {
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
     PREVSTATENUMBER = STATENUMBER;
  }
}

void PlayMode( )
{
  // the button should say quiz
  //everything should be displayed
  DRAWFUNCTION = true;
  //sliders should be dynamic
  println("Play mode.");
}
void Question1()
{
  // the button should say continue
  //no graph
  DRAWFUNCTION = false;
  //sliders are static
  //yes equation: 0.5sin(2x)
  println("Q1");
}
void Question2()
{
  // the button should say continue
  //yes graph
  DRAWFUNCTION = true;
  //sliders are static
  // no equation displayed : 0.6cos(3x)
  println("Q2");
}

