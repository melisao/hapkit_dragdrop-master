/*****************************
* ArduinoWaves functions file.
*  This file contains the functions to feel waves using a Hapkit and sends 
*  the position and force at the handle to be ploted by processing.
*  
*
*  author: Melisa Orta Martinez
*           melisao@stanford.edu
*/


// Includes
#include <math.h>

//choose Three D printed HApkit or comment out for laser cuted version. (motor dependant)
//#define THREE_D_PRINT 

//apparently #ifdef is not fully supported by arduino: https://code.google.com/p/arduino/issues/detail?id=906
// just commenting out for now then.
//#ifdef THREE_D_PRINT
  double motorcalibration =  0.03;
//#else
  //double motorcalibration =  0.0053;
//#endif


// Pin Declares 
int pwmPinA = 5;       // to send PWM signal to motor A
int dirPinA = 8;       // to send direction signal to motor A
int sensorPosPinA = A2; // to read the MR sensor values

// Position tracking variables
int updatedPos = 0;          //keeps track of the updated value of the MR sensor reading
int rawPos = 0;              //current raw reading from MR sensor
int lastRawPos = 0;          //last raw reading from MR sensor
int lastLastRawPos = 0;      //last last raw reading from MR sensor
int flipNumber = 0;          //keeps track of the number of flips over the 180deg mark
int tempOffset = 0;
int rawDiff = 0;
int lastRawDiff = 0;
int rawOffset = 0;
int lastRawOffset = 0;
const int flipThresh = 700;  //threshold to determine whether or not a flip over the 180 degree mark occurred
boolean flipped = false;


//kinematics variables
double x = 0;           //position of the handle [m]
double lastx = 0;       //last x position of the handle
double vel = 0;         //velocity of the handle
double lastVel = 0;     //last velocity of the handle
double lastLastVel = 0; //last last velocity of the handle

double thetaSector = 0;

// Force output variables
double force = 0;           //force at the handle
double Tm = 0;              //torque of the motor
double duty = 0;            //duty cylce (between 0 and 255)
unsigned int output = 0;    //output command to the motor

// Kinematic Parameters
double lx = 0.065659;   //[m]
double rp = 0.004191;   //[m]
double rs = 0.073152;   //[m]

// MR calibration fit
double m = -0.0106; //-    //linear curve fit (theta_s = m*pos + b) to ME sensor data
double b = 9.8235;


// Processing variables
String xAPrint = "0";
String fAPrint = "0";
int constant = 10000;
int count = 0;

// Variables that can be changed by processing code:
int functionNumber = 0;        //the function that should be playing right now
double amplitude = 0;         // a number between 0 and 1 that represents the proportion of amplitude
double freq = 0;             // the number of cycles in half of the screen.

char serialInputBuffer[4]; 
int lengthInputBuffer = 4; //need to flush out the ENTIRE transmission! Otherwise it gets super confused

/*****************************
* function name: setup
* inputs:            
* outputs:
* module vars modified:
* module vars used:
* globals modified:
* globals used:
* description:   
*****************************/
void setup() 
{
  // Set up serial communication
  Serial.begin(9600);
  
  // Set PWM frequency 
  setPwmFrequency(pwmPinA,1); 
  
  // Input pins
  pinMode(sensorPosPinA, INPUT); // set MR sensor pin to be an input

  // Output pins
  pinMode(pwmPinA, OUTPUT);  // PWM pin for motor A
  pinMode(dirPinA, OUTPUT);  // dir pin for motor A
  
  // Initialize motor 
  analogWrite(pwmPinA, 0);     // set to not be spinning (0/255)
  digitalWrite(dirPinA, LOW);  // set direction
  
  // Initialize position valiables
  lastLastRawPos = analogRead(sensorPosPinA);
  lastRawPos = analogRead(sensorPosPinA);
  
}

// --------------------------------------------------------------
// Main Loop
// --------------------------------------------------------------
void loop()
{
     
  //*************************************************************
  //*** Section 1. Compute position in counts (do not change) ***  
  //*************************************************************

  // Get voltage output by MR sensor
  rawPos = analogRead(sensorPosPinA);  //current raw position from MR sensor

  //calculate differences between MR sensor readings
  rawDiff = rawPos - lastRawPos;          //difference btwn current raw position and last raw position
  lastRawDiff = rawPos - lastLastRawPos;  //difference btwn current raw position and last last raw position
  rawOffset = abs(rawDiff);
  lastRawOffset = abs(lastRawDiff);
  
  // Update position record-keeping vairables
  lastLastRawPos = lastRawPos;
  lastRawPos = rawPos;
  
  // Keep track of flips over 180 degrees
  if((lastRawOffset > flipThresh) && (!flipped))   //enter this anytime the last offset is greater than the flip threshold AND it has not just flipped
  {
    if(lastRawDiff > 0)    //check to see which direction the drive wheel was turning
    {
      flipNumber--;   //cw rotation for how I've been playing with MR sensor 
    } 
    else //if(rawDiff<0)
    {
      flipNumber++;   //ccw rotation for how I've been playing with MR sensor
    }
    if(rawOffset > flipThresh) //check to see if the data was good and the most current offset is above the threshold
    {
      updatedPos = rawPos + flipNumber*rawOffset;      //update the pos value to account for flips over 180deg using the most current offset 
      tempOffset = rawOffset;
    }else    //in this case there was a blip in the data and we want to use lastactualOffset instead
    {
      updatedPos = rawPos + flipNumber*lastRawOffset;    //update the pos value to account for any flips over 180deg using the LAST offset
      tempOffset = lastRawOffset;
    }
    flipped = true;    //set boolean so that the next time through the loop won't trigger a flip
  }
  else  //anytime no flip has occurred
  {
    updatedPos = rawPos + flipNumber*tempOffset;    //need to update pos based on what most recent offset is 
    flipped = false;
  }
  
  //*************************************************************
  //*** Section 2. Compute position in meters *******************
  //*************************************************************

 thetaSector = m*updatedPos + b;      //based on linear-fit (theta_s is in degrees)
 //---Enter calculations to find "x" and "vel" of handle-----------
 thetaSector = (thetaSector *PI)/180; //convert thetaSector to radians
 x = lx*thetaSector;                  //x-position of sector pulley in [m]

 vel = -(.95*.95)*lastLastVel + 2*.95*lastVel + (1-.95)*(1-.95)*(x-lastx)/.0001;  //filtered velocity (2nd order filter)
//------Update variables------ 
lastx = x;
lastLastVel = lastVel;
lastVel = vel;
 
       
//*************************************************************
//*** Section 3. Assign a motor output force in Newtons *******  
//*************************************************************
  
   
   switch (functionNumber)
   {
    case 0:
       force = 0; 
     break;
     case 1:
       force = (2*amplitude)*sin((freq * x*2*PI)/0.05);
     break;
     case 2:
       force = (2*amplitude)*cos((freq * x*2*PI)/0.05);
      break;
     case 3:
       force = -2*amplitude*(x/0.05);
     break;
    default:
     force = 0;
   }
   // clip the force, never want more than 2 newtons. Maybe revise this number. if it gets revised need
   // to change all the constants. 
   if (force >2)
   {
       force = 2;
   }
   else if (force < -2)
   {
     force = -2;
   }
   xAPrint = String((int)(x*constant));
   fAPrint = String((int)(force*500));
  
  //*************************************************************
  //*** Section 4. Force output (do not change) *****************
  //*************************************************************
  //Determine correct direction
  if(force < 0)  //[N]
  {
    digitalWrite(dirPinA, HIGH);
    //Serial.print("+");
  } else
  {
    digitalWrite(dirPinA, LOW);
    //Serial.print("-");
  } 
 
   double force1 = abs(force);
   Tm = rp/rs * lx * force1;        // corresponding motor torque based on force
   duty = sqrt(Tm/motorcalibration);          // map motor torque to PWM duty cycle
  
  if (duty > .95) 
    {
      duty = .95;                 // output a maximum of 80% duty cycle
    }    
  if (duty < 0)
    { 
      duty = 0;
    }  
  output = (int)(duty * 255);      // convert duty cycle to output signal
  //Serial.print(output);
  //Serial.print("\n");
  analogWrite(pwmPinA,output);    // output the signal
    
  
  //********************** Data to send and receive from Processing **********************
  
  if (Serial.available() > 3) 
    {
        // read the incoming buffer:
        Serial.readBytesUntil(255,serialInputBuffer,lengthInputBuffer);
        functionNumber = serialInputBuffer[0];
        amplitude = serialInputBuffer[1];
        amplitude = amplitude/100;
        if (amplitude > 1)
        {
          amplitude = 1;
        }
        else
        {
          if (amplitude < -1)
          {
            amplitude = -1;
          }
        }
        freq = serialInputBuffer[2];
        freq = freq/10;
      }
  
  if(count > 6) {
    
    Serial.print(xAPrint);
    Serial.print(",");
    Serial.print(fAPrint);
    Serial.print("\n");
    
   
    count = 0;
  } else {
    count ++; 
  }
  
}

// --------------------------------------------------------------
// Function to set PWM Freq -- DO NOT EDIT
// --------------------------------------------------------------
void setPwmFrequency(int pin, int divisor) {
  byte mode;
  if(pin == 5 || pin == 6 || pin == 9 || pin == 10) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 64: mode = 0x03; break;
      case 256: mode = 0x04; break;
      case 1024: mode = 0x05; break;
      default: return;
    }
    if(pin == 5 || pin == 6) {
      TCCR0B = TCCR0B & 0b11111000 | mode;
    } else {
      TCCR1B = TCCR1B & 0b11111000 | mode;
    }
  } else if(pin == 3 || pin == 11) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 8: mode = 0x02; break;
      case 32: mode = 0x03; break;
      case 64: mode = 0x04; break;
      case 128: mode = 0x05; break;
      case 256: mode = 0x06; break;
      case 1024: mode = 0x7; break;
      default: return;
    }
    TCCR2B = TCCR2B & 0b11111000 | mode;
  }
}

