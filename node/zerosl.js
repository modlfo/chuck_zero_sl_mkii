var midi = require('midi');


var ZeroSLPositions = {
  LeftUpButton : 24,
  LeftDownButton : 32,
  RightUpButton : 40,
  RightDownButton : 49,

  LeftLCD : 0,
  RightLCD : 1,

  Row1 : 1,
  Row2 : 2,

  Encoders : 56,
  Knobs : 8 ,
  Sliders : 16
};

function ZeroSL(){
  this.input = new midi.input();
  this.output = new midi.output();
  console.log(this.input.getPortCount());
  console.log(this.input.getPortName(2));
}

ZeroSL.prototype.open = function(device) {
  /* Search the input port */
  var ports = this.input.getPortCount();
  var name = '';
  for (var i = 0; i < ports; i++) {
    name = this.input.getPortName(i);
    if(name.indexOf(device)>-1){
      this.input.openPort(i);
      console.log('Opening input '+name);
      break;
    }
  }
  /* Search the output port */
  ports = this.output.getPortCount();
  for (i = 0; i < ports; i++) {
    name = this.output.getPortName(i);
    if(name.indexOf(device)>-1){
      this.output.openPort(i);
      console.log('Opening output '+name);
      break;
    }
  }
  /* Send conenct message */
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,1,1,247]);
  /* Callback for messages */
  this.input.on('message', function(deltaTime, message) {
    console.log('m:' + message + ' d:' + deltaTime);
  });
};

ZeroSL.prototype.close = function() {
  this.clear();
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,1,0,247]);
  this.input.closePort();
  this.output.closePort();
};

ZeroSL.prototype.clear = function() {
  this.output.sendMessage([240,0,32,41,3,3,18,0,4,0,2,2,1,247]);

  for(var i=0; i<8; i=i+1){
    this.setLedRing(i,0);
    this.setLedButton(ZeroSLPositions.LeftUpButton+i,0);
    this.setLedButton(ZeroSLPositions.LeftDownButton+i,0);
    this.setLedButton(ZeroSLPositions.RightUpButton+i,0);
    this.setLedButton(ZeroSLPositions.RightDownButton+i,0);
  }
};

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
	if(left_right===0 && row == 1)
      display=1;
    if(left_right==1 && row == 1)
      display=2;
    if(left_right===0 && row == 2)
      display=3;
    if(left_right==1 && row == 2)
      display=4;
  	// crop the string if larger than 8 characters
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
};

ZeroSL.prototype.setLedRing = function(ring,value) {
  this.output.sendMessage([176,112+ring,value]);
};

ZeroSL.prototype.setLedButton = function(control,value) {
  this.output.sendMessage([176,control,value]);
};

ZeroSL.prototype.write = function(s,display,position) {
	var msg = [240,0,32,41,3,3,18,0,4,0,2,1,position,display,4];
  var s_length = s.length;
  // append the characters to the array
  for(var i;i<s_length;i=i+1){
      msg.push(s[i]);
  }
  msg.push(247); // finalize the message
  this.output.sendMessage(msg);
};



function Visualizer(){
  this.visible = false;
  this.label = '';
  this.value = 0.0;
  this.controller = null;
}

Visualizer.prototype.update = function(v,i) {
};


function Control(){
  this.enabled = true;
  this.int_value = 0;
  this.raw_value = 0.0;
  this.name = '';
  this.cc_value = 0;

  this.visualizers = [];
}

Control.prototype.handle = function(control,value) {
  return 0;
};

Control.prototype.show = function() {
  for (var i = 0; i < visualizers.length; i++) {
    visualizers[i].update(raw_value,int_value);
  }
};



/* Led visualizer */
function Led(){
  Visualizer.call(this);
  this.cc_value = 0;
}

Led.prototype = new Visualizer();
Led.prototype.constructor = Led;

Led.prototype.update = function(v,i) {
  if(this.controller)
    this.controller.setLedButton(cc_value,i);
};


/* Numeric visualizer */
function Numeric(){
  Visualizer.call(this);
  this.column = 0;
  this.lcd = 0;
  this.lcd = 0;
  this.min = 0.0;
  this.max = 1.0;
  this.int_float = false;
}

Numeric.prototype = new Visualizer();
Numeric.prototype.constructor = Numeric;

Numeric.prototype.update = function(v,i) {
  if(this.controller){
    var val = (max-min)*v+min;
    var s = '';
    if(int_float)
      s = i.toString();
    else
      s = val.toFixed(3);
    this.controller.writeLabel(this.label,this.lcd,ZeroSLPositions.Row1,this.column);
    this.controller.writeLabel(s,this.lcd,ZeroSLPositions.Row2,this.column);
  }
};

/* LedRing visualizer */
function LedRing(){
  Visualizer.call(this);
  this.column = 0;
}

LedRing.prototype = new Visualizer();
LedRing.prototype.constructor = LedRing;

LedRing.prototype.update = function(v,i) {
  if(this.controller){
    var ring_value = Math.round(v*12.0);
    this.controller.setLedRing(this.column,ring_value);
  }
};


var obj = new ZeroSL();

obj.open('ZeRO MkII 20:1');

obj.close();
