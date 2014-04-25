var midi = require('midi');


LeftUpButton = 24;
LeftDownButton = 32;
RightUpButton = 40;
RightDownButton = 49;

LeftLCD = 0;
RightLCD = 1;

Row1 = 1;
Row2 = 2;

Encoders = 56;
Knobs = 8 ;
Sliders = 16;

function ZeroSL(){
  this.input = new midi.input();
  this.output = new midi.output();
  console.log(this.input.getPortCount());
  console.log(this.input.getPortName(1));
}

ZeroSL.prototype.open = function(device) {
  /* Search the input port */
  var ports = this.input.getPortCount();
  for (var i = 0; i < ports; i++) {
    var name = this.input.getPortName(i);
    if(name.indexOf(device)>-1){
      this.input.openPort(i);
      console.log('Opening input '+name);
      break;
    }
  };
  /* Search the output port */
  ports = this.output.getPortCount();
  for (var i = 0; i < ports; i++) {
    var name = this.output.getPortName(i);
    if(name.indexOf(device)>-1){
      this.output.openPort(i);
      console.log('Opening output '+name);
      break;
    }
  };
  /* Send conenct message */
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,1,1,247]);
  /* Callback for messages */
  this.input.on('message', function(deltaTime, message) {
    console.log('m:' + message + ' d:' + deltaTime);
  });
}

ZeroSL.prototype.close = function() {
  this.clear();
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,1,0,247]);
  this.input.closePort();
  this.output.closePort();
}

ZeroSL.prototype.clear = function() {
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,2,2,1,247]);

  for(var i=0; i<8; i=i+1){
    this.setLedRing(i,0);
    this.setLedButton(LeftUpButton+i,0);
    this.setLedButton(LeftDownButton+i,0);
    this.setLedButton(RightUpButton+i,0);
    this.setLedButton(RightDownButton+i,0);
  }
}

function appendRepeated(s,sub,n)
{
    var tmp = s;
    for(var i=0; i<n; i=i+1)
    {
      tmp=tmp+sub;
    }
    return tmp;
}

ZeroSL.prototype.writeLabel = function(ss,left_right,row,column) {
	var s = ss.toString();
	var display = 0;
	var position = 0;
	var str = '';
	if(left_right==0 && row == 1)
      display=1;
    if(left_right==1 && row == 1)
      display=2;
    if(left_right==0 && row == 2)
      display=3;
    if(left_right==1 && row == 2)
      display=4;
  	// crop the string if larger than 8
    if(s.length>=8)
      str = s.substring(0, 8);
    else
    {
      var spaces = 8 - s.length;
      var pre_s =  appendRepeated(""," ",spaces/2);
      str = pre_s+s;
      spaces = 8 - str.length;
      str = appendRepeated(str," ",spaces);
    }
    this.write(str,display,(column-1)*9);
}

ZeroSL.prototype.setLedRing = function(ring,value) {
  this.output.sendMessage([176,112+ring,value]);
}

ZeroSL.prototype.setLedButton = function(control,value) {
  this.output.sendMessage([176,control,value]);
}

ZeroSL.prototype.write = function(s,display,position) {
	var msg = [240,0,32,41,3,3,18,0,4,0,2,1,position,display,4];
  s_length = s.length;
  // append the characters to the array
  for(var i;i<s_length;i=i+1){
      msg.push(s[i]);
  }
  msg.push(247); // finalize the message
  this.output.sendMessage(msg);
}

var obj = new ZeroSL();

obj.open('USB Uno MIDI Interface');

obj.close();
