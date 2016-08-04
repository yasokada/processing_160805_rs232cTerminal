import processing.serial.*;
import controlP5.*;
import java.util.*;

/*
 * v0.2 2016 Aug. 05
 *   - show serial rx text on the window
 *   - add [dispLabel]
 *   - add suppressToNLines()
 * v0.1 2016 Aug. 05
 *   - remove [sliderValue]
 *   - remove [numSerial]
 *   - remove [previousSecond]
 *   - remove checkbox:Checkbox
 *   - remove [kIntervalUI]
 *   - remove [kAmplitudeName*]
 *   - remove amplitudeUI_setup()
 *   - change serial baud rate from 9600 to 115200 bps
 *   - remove getIntervaledValue()
 *   - remove intervalUI_setup()
 *   - remove turnOnOffUI_setup()
 *   - remove 1 second interval in draw()
 *   - remove sendTestString()
 *   - echo back on serial rx 
 * ============== branched from processing_160716_uartSender v0.5 ================
 * v0.5 2016 Jul. 25
 *   - add checkbox to turn ON/OFF the output of items
 *   - refactor for array usage
 * v0.4 2016 Jul. 22
 *   - comment out index serial tx
 *   - add slider to change interval second
 *   - add slider to change amplitude of the data
 *     + modify sendTestString() to use the amplitude
 *     + add amplitudeUI_setup()
 * v0.3 2016 Jul. 19
 *   - add ScrollableList for COM port selection
 *   - remove COM button
 *   - remove slider
 * v0.2 2016 Jul. 17
 *   - add getIntervaledValue()
 * v0.1 2016 Jul. 16
 *   - send text through COM port
 *   - add sendTestString() to send interval
 *   - add 1 second interval in draw()
 *   - add button to open COM port
 *   - add slider for COM port setting
 */

Serial myPort;

ControlP5 cp5;
int curSerial = -1;

ControlP5 btnOpen;

String dispLabel = "";

void setup() {
  size(500,500);
  frameRate(10);
  
  cp5 = new ControlP5(this);
  
  List lst = Arrays.asList(Serial.list());
  
  cp5.addScrollableList("dropdownCOM")
     .setPosition(100, 100)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(Serial.list());     
}

void controlEvent(ControlEvent theEvent) {
}

void dropdownCOM(int n)
{
  println(n);
  curSerial = n;
  if (myPort != null) {
     myPort.stop(); 
     myPort = null;
  }
  myPort = new Serial(this, Serial.list()[curSerial], 115200);
  myPort.bufferUntil('\n');  
}

void serialEvent(Serial myPort) { 
   String mystr = myPort.readStringUntil('\n');
   mystr = trim(mystr);
   println(mystr);
   
   if (dispLabel.length() > 0) {
    dispLabel = dispLabel + "\r\n";
   }
   dispLabel = dispLabel + mystr;
   dispLabel = suppressToNLines(dispLabel, /*nlines=*/15);
}

String suppressToNLines(String srcstr, int nlines)
{
  String[] wrk = split(srcstr, '\n');
  int loop = min(wrk.length, nlines + 1);

  int strt = 0;
  if ( wrk.length == (nlines + 1) ) {
     strt = 1; 
  }

  println(loop);

  String res = "";
  for(int idx = strt; idx < loop; idx++) {
    if (res.length() > 0) {
      res = res + '\n';
    }
    res = res + wrk[idx];
  }
  return res;
}

//void openPort() {
//   println("Open Port"); 
//   if (myPort != null) {
//      myPort.stop(); 
//   }
//   myPort = new Serial(this, Serial.list()[(int)curSerial], 115200);
//   myPort.bufferUntil('\n');
// }


void draw() {
  background(150);  
  
  if (dispLabel.length() > 0) {
    fill(50);
    text(dispLabel, 10, 10, 700, 80);
  }
}