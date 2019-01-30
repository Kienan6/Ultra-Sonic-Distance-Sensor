/*
By: Kienan O'Brien
Ista 303
Project 2
*/

import processing.serial.*;

Serial port;
String coords;

 
 int[][] bars; //stores information from serial
 int[][] oldbars;//used in animation
 int animNum = 0;//iterator for which bar to animate
 int numBars = 60;//number of bars to show
 int modifier = 8;//default, modified later
 
 //colors
 color tomato = color(255,99,71);
 color gold = color(255,215,0);
 
 int modset = 0;//boolean for setting a new modifier
 
 //updates bars on new data over serial
 void readPort() {
   //wait for data
   if(port.available() > 0) {
     //read till line end
     coords = port.readStringUntil('\n');
     if(coords != null) {
       coords.trim();
       int split_point = coords.indexOf(',');
       if (split_point <= 0) return;        // If data does not contain a comma, then disregard it.
       
       //println(coords);
       float toks[] = float(splitTokens(coords, ","));
       for( int i = 0; i < numBars; i++) {
         //store new height value at respective index
         if(bars[i][0] == int(toks[0])) {
           bars[i][0] = int(toks[0]);
           bars[i][1] = int(toks[1]);
         }
       }
     }
   }
 }
  //animating old, current for reference, mod is the modifier
  int animateBar(int old, int current, int mod) {//update bars array
  
   if(current > old) {//animate upwards
     old += mod;
     //return correct size independent of modifier
     if(old > current)
       return current;
   } else { //animate downwards
     old -= mod;
     //return correct size independent of modifier
     if(old < current) 
       return current;
   }
   
   //return new height
   return old;
 }
 void setup() {
   
   size(1150,900);
   frameRate(120);
   //initialize arrays
   bars = new int[numBars][2];//size
   oldbars = new int[numBars][2];//size
   
   background(178,34,34);
   //serial information
   String name = Serial.list()[0];
   port = new Serial(this, name, 9600);
   //set arrays angle, and height to 0
   for(int i = 0; i < numBars; i++) {
     bars[i][0] = (180/numBars)*i;
     bars[i][1] = 0;
     oldbars[i][0] = (180/numBars)*i;
     oldbars[i][1] = 0;
   }
 }
 //loops very fast to keep current graph accurate
 //only modifies graph when it finds a change
 void draw() {
   readPort();
   delay(10);
   background(178,34,34);//redraw background every time
   
   if(animNum == numBars) {//gone through all to see if they need to be animated
       animNum = 0;
       animNum = 0;
   }
   //set new modifier if need be
   if(modset == 0) {
     modifier = abs(bars[animNum][1]-oldbars[animNum][1])/12;//10 steps to animate regardless of new height. tall bars faster and small ones smoother
     if(modifier == 0)//initial condition
     modifier = 8;
   }
   //draw background
   pushMatrix();
   translate(width*0.5, height*0.5);
   fill(tomato);
   ellipse(0,0,540,540);
   fill(32,178,170);
   ellipse(0,0,390,390);
   fill(gold);
   ellipse(0,0, 200,200);
   popMatrix();
   
   //draw all bars
   for(int i = 0; i < numBars; i++) {//draw all bars
     pushMatrix();
     fill(gold);
     //creates radial graph
     translate(width*0.5, height*0.5);//center of sketch
     translate( 100*cos( radians( 180+((i+1)*(180/numBars)) ) ), 100*sin( radians( 180+((i+1)*(180/numBars)) ) ) );
     rotate(radians( 90+(i*(180/numBars)) ));
     
     //width of 4 rectangles
     rect(0,0, 4, oldbars[i][1]);//draw bar
     popMatrix();
   }
   
   
   //every frame increases or decreases a bars size based on the current 'bars' array
   //when the current bar height matches the animating bar height kept in an old array it 
   //will index the animNum which goes through till it finds another bar that needs to be animated
   if(oldbars[animNum][1] == bars[animNum][1]){//done with animation
     oldbars[animNum][1] = bars[animNum][1];//even out the bar to the correct position kept in the bars array 
     modset = 0;
     animNum++;//move the bar to animate
   } else {
     modset = 1;
     oldbars[animNum][1] = animateBar(oldbars[animNum][1], bars[animNum][1], modifier);//animate the old set of data to the new set of data
   }
 }
