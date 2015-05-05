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
  cp5.getController("startQuiz").getCaptionLabel().setText("Start Quiz");
  //everything should be displayed
  DRAWFUNCTION = true;
  //sliders should be dynamic
  cp5.getController("sliderAmp").setLock(false);
  cp5.getController("sliderFreq").setLock(false);
  // Remove function frpm droptarget
  fnblocks.hide = false;
  droptarget.removeCurFn();
  println("Play mode.");
}

void Question1()
{
  // the button should say continue
  cp5.getController("startQuiz").getCaptionLabel().setText("Continue");
  //no graph
  DRAWFUNCTION = false;
  //sliders are static
  cp5.getController("sliderAmp").setLock(true);
  cp5.getController("sliderFreq").setLock(true);
  //yes equation: 0.5sin(2x)
  fnblocks.hide = true;
  droptarget.removeCurFn();
  fnblocks.updateBlock(1, "sin", 0.5, 2,true);
  droptarget.dropfn(fnblocks.getFn(1));
  println("Q1");
}
void Question2()
{
  // the button should say continue
  cp5.getController("startQuiz").getCaptionLabel().setText("Continue");
  //yes graph
  DRAWFUNCTION = true;
  //sliders are static
  cp5.getController("sliderAmp").setLock(true);
  cp5.getController("sliderFreq").setLock(true);
  // no equation displayed : 0.6cos(3x)
  fnblocks.hide = true;
  droptarget.removeCurFn();
  fnblocks.updateBlock(2, "cos", 0.6, 3,true);
  droptarget.dropfn(fnblocks.getFn(2));
  println("Q2");
}

