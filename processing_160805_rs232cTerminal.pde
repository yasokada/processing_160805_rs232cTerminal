import processing.serial.*;
import controlP5.*;
import java.util.*;
import java.text.SimpleDateFormat;

/*
 *   - add addToStringWithNLineLimited()
 *   - rename [dispLabel] to [rxLabel]
 * v0.4 2016 Aug. 06
 *   - send text of input field by [Enter]
 *   - modify controlEvent() to handle input of textfield
 *   - add txInputField_setup()
 * v0.3 2016 Aug. 05
 *   - show current millisecond
 *   - show current timestamp
 *   - tweak locations of components
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

String rxLabel = "";
String txLabel = "";

void setup() {
  size(700, 500);
  frameRate(10);
  
  cp5 = new ControlP5(this);
  
  txInputField_setup();
  
  List lst = Arrays.asList(Serial.list());  
  cp5.addScrollableList("dropdownCOM")
     .setPosition(20, 20)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(Serial.list());     
}

void txInputField_setup()
{
  cp5.addTextfield("txstring")
     .setPosition(240,20)
     .setSize(200,30)
     .setFont(createFont("arial",16))
     .setAutoClear(false)
     ;  
     
  //cp5.addButton("btnTx")
  //   .setLabel(" TX ")
  //   .setPosition(460, 20)
  //   .setFont(createFont("arial",16))
  //   .setSize(60,30);
}

void btnTx() {
  // this causes error 2016 Jul. 06
//  String str = cp5.get(Textfield.class,"btnTx").getText();
//  print(str);
  println("btnTx");
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    String txt = theEvent.getStringValue();
    
    if (curSerial > 0) {
      txt = txt + "\n";
      myPort.write(txt);      
    }
  }
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

String addToStringWithNLineLimited(String srcstr, String dststr, int nlines)
{
  if (dststr.length() > 0) {
    dststr = dststr + "\r\n";    
  }
  dststr = dststr + srcstr;
  dststr = suppressToNLines(dststr, nlines);
  return dststr;
}

void serialEvent(Serial myPort) { 
   String mystr = myPort.readStringUntil('\n');
   mystr = trim(mystr);
   println(mystr);
      
   String addstr = getCurrentTimeStamp() + "." + getCurrentMilliSecond() + " : ";
   addstr = addstr + mystr;
   rxLabel = addToStringWithNLineLimited(addstr, rxLabel, /*nlines=*/15);
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

String getCurrentTimeStamp() {
    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");//dd/MM/yyyy
    Date now = new Date();
    String strDate = sdfDate.format(now);
    return strDate;
}

String getCurrentMilliSecond() {
  long millis = System.currentTimeMillis() % 1000;
//  return String.valueOf(millis);
  return String.format("%03d", millis);
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
  
  if (rxLabel.length() > 0) {
    fill(50);
    text(rxLabel, 10, 100, 700, 400);
  }
}