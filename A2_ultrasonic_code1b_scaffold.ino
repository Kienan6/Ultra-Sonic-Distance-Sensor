/* Adapted from open source HC-SR04 Arduino driver.
 *  
 * Hardware Connections:
 *  Arduino | HC-SR04 
 *  -------------------
 *    5V    |   VCC     
 *    2     |   Trig     
 *    3     |   Echo     
 *    GND   |   GND
 *  
 * License:
 *  Public Domain
 */

 /*
  * 
  * Modified by Kienan O'Brien
  * Ista 303
  * Project 2
  */

#include <Servo.h>

// Servo
Servo myservo;  // create servo object to control a servo
int pos = 0;    // variable to store the servo position
int delta = 3;  // Angle to move at each iteration

float range = 0.0;
// Pins
const int TRIG_PIN = 2;
const int ECHO_PIN = 3;
const int SERVO_PIN = 12;

// Anything over 400 cm (23200 us pulse) is "out of range"
const unsigned int MAX_DIST = 23200;


// Measure distance from the ultrasonic sensor, return value in millimeters. 
// (This code is from the open source HC-SR04 Arduino driver
// modified from a forum post for the BangGood version of this sensor). 
float measureDistanceCM() {
  unsigned long t1;
  unsigned long t2;
  unsigned long pulse_width;
  float cm;
  float inches;

  // Hold the trigger pin high for at least 10 us
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Wait for pulse on echo pin

  unsigned long wait1 = micros();
  while ( digitalRead(ECHO_PIN) == 0  ) {
    if ( micros() - wait1 > MAX_DIST ) {
        //Serial.println("wait1 Out of range");
        return -1;
    }
  }
  // Measure how long the echo pin was held high (pulse width)
  // Note: the micros() counter will overflow after ~70 min
  t1 = micros();
    while ( digitalRead(ECHO_PIN) == 1  ) {
    if ( micros() - t1 > MAX_DIST ) {
        Serial.println("wait2 Out of range");
        break;//this loop is broken out of and an extreme condition is taken care of by returning 400.0
        //had an issue with this loop pausing operation
    }
  } 
  
  t2 = micros();
  pulse_width = t2 - t1;
  // Calculate distance in centimeters and inches. The constants
  // are found in the datasheet, and calculated from the assumed speed 
  // of sound in air at sea level (~340 m/s).
  // ISTA 303 TODO: Include appropraite values for calculating the distance
  // here, found in the datasheet. 
  
  cm = pulse_width/58;//time to cm
  inches = pulse_width/148;//converrt to inches
  
  // Wait at least 60ms before next measurement
  delay(60);

  // Print out results
  if ( pulse_width > MAX_DIST ) {
    //Serial.println("Out of range");
    return 400.0;
  } else {    
    //Serial.print(cm);
    //Serial.print(" cm \t");
    //Serial.print(inches);
    //Serial.println(" in");    
    return cm;
  }
  
}


void setup() {
  // Setup ultrasonic sensor pin modes
  pinMode(TRIG_PIN, OUTPUT);  
  digitalWrite(TRIG_PIN, LOW);

  // Enable serial port output
  Serial.begin(9600);

  // Let the user know that the code is starting up... 
  Serial.println("Initializing...");
  delay(2000);
  
  // Step 3: Output angle and range to serial port
  Serial.print(pos);
  Serial.print(",");
  Serial.println(range);
  
  // Initialize servo
  myservo.attach(SERVO_PIN);  // attaches the servo on SERVO_PIN to the servo object
  delay(1000);
}


void loop() {
  if(pos >= 180){//reset position on > 180
    pos = 0;
  }
  // Step 1: Move to specific angle   
  myservo.write(pos);
  // Step 1A: Brief delay to allow servo to move to position and settle
  delay(250);      
  
  // Step 2: Measure range
  float range = -1;
  while(range == -1){
   range = measureDistanceCM();
  }
  //output serial information to be read in processing
  Serial.print(pos);
  Serial.print(",");
  Serial.println(range);
  
  // Step 4: Calculate new angle to move to
  pos += delta;//jump delta degrees
  
}


