var midi = require('midi');


ZeroPos = 
 {

  LeftUpButton : 24,
  LeftDownButton : 32,
  RightUpButton : 40,
  RightDownButton : 49,

  LeftLCD : 0,
  RightLCD : 1,

  Row1 : 1,
  Row2 : 2,

  Encoders : 56,
  Knobs : 8,
  Sliders : 16
};

function ZeroSL(){
  this.input = new midi.input();
  this.input.ignoreTypes(false, false, false);
  this.output = new midi.output();
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

  for(i=0; i<8; i=i+1){
    this.setLedRing(i,3);
    this.setLedButton(24+i,127);
    this.writeLabel(i,0,1,i+1);
    this.writeLabel(i,0,2,i+1);
  }
};

ZeroSL.prototype.setControlHandler = function(newHandler){
  this.controlHandler = newHandler;
  /* Callback for messages */
  this.input.on('message', function(deltaTime, message) {
    //console.log(message);
    if(message[0]==176){
      if(newHandler){
        newHandler.handle(message[1],message[2]);
      }
    }
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
    this.setLedButton(ZeroPos.LeftUpButton+i,0);
    this.setLedButton(ZeroPos.LeftDownButton+i,0);
    this.setLedButton(ZeroPos.RightUpButton+i,0);
    this.setLedButton(ZeroPos.RightDownButton+i,0);
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
      var pre_s =  appendRepeated('',' ',spaces/2);
      str = pre_s+s;
      spaces = 8 - str.length;
      str = appendRepeated(str,' ',spaces);
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
  for(var i=0;i<s_length;i++){
      msg.push(s.charCodeAt(i));
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
  for (var i = 0; i < this.visualizers.length; i++) {
    this.visualizers[i].update(this.raw_value,this.int_value);
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
    this.controller.setLedButton(this.cc_value,i);
};


/* Numeric visualizer */
function Numeric(){
  Visualizer.call(this);
  this.column = 0;
  this.lcd = ZeroPos.LeftLCD;
  this.min = 0.0;
  this.max = 1.0;
  this.int_float = true;
}

Numeric.prototype = new Visualizer();
Numeric.prototype.constructor = Numeric;

Numeric.prototype.update = function(v,i) {
  if(this.controller){
    var val = (this.max-this.min)*v+this.min;
    var s = '';
    if(this.int_float)
      s = val.toFixed(3);
    else
      s = i.toString();
    this.controller.writeLabel(this.label,this.lcd,ZeroPos.Row1,this.column);
    this.controller.writeLabel(s,this.lcd,ZeroPos.Row2,this.column);
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

/* Items visualizer */
function Items(){
  Visualizer.call(this);
  this.column = 0;
  this.lcd = 0;
  this.items = [];
}

Items.prototype = new Visualizer();
Items.prototype.constructor = Items;

Items.prototype.update = function(v,i) {
  if(this.controller){
    var fixed_index = i;
    if(fixed_index >= this.items.length)
      fixed_index = this.items.length;
    if(fixed_index<0)
      fixed_index = 0;
    this.controller.writeLabel(this.label,this.lcd,ZeroPos.Row1,this.column);
    this.controller.writeLabel(this.items[fixed_index],this.lcd,ZeroPos.Row2,this.column);
  }
};

/* ToggleButton controller */
function ToggleButton(){
  Control.call(this);
}

ToggleButton.prototype = new Control();
ToggleButton.prototype.constructor = ToggleButton;

ToggleButton.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    if(v!==0){
      if(this.int_value!==0){
        this.int_value = 0;
        this.raw_value = 0.0;
      }
      else {
        this.int_value = 127;
        this.raw_value = 1.0;
      }
      this.show();
      return 1;
    }
  }
  return 0;
};

/* PushButton controller */
function PushButton(){
  Control.call(this);
}

PushButton.prototype = new Control();
PushButton.prototype.constructor = PushButton;

PushButton.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    if(v===0){
        this.int_value = 0;
        this.raw_value = 0.0;
      }
      else {
        this.int_value = 127;
        this.raw_value = 1.0;
      }
      this.show();
      return 1;
    }
  return 0;
};

/* CountButton controller */
function CountButton(){
  Control.call(this);
  this.min = 0;
  this.max = 127;
}

CountButton.prototype = new Control();
CountButton.prototype.constructor = CountButton;

CountButton.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    if(v!==0){
      this.int_value++;
      if(this.int_value>this.max)
        this.int_value = this.min;
      if(this.int_value<this.min)
        this.int_value = this.max;
      var range = this.max - this.min;
      var delta = this.int_value-this.min;
      this.raw_value = delta/range;
      this.show();
      return 1;
    }
  }
  return 0;
};

/* Knob controller */
function Knob(){
  Control.call(this);
  this.min = 0;
  this.max = 127;
}

Knob.prototype = new Control();
Knob.prototype.constructor = Knob;

Knob.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    this.int_value = v;
    var range = this.max-this.min;
    var delta = this.int_value-this.min;
    this.raw_value = delta/range;
    this.show();
    return 1;
  }
  return 0;
};

/* KnobInt controller */
function KnobInt(){
  Control.call(this);
  this.min = 0;
  this.max = 127;
}

KnobInt.prototype = new Control();
KnobInt.prototype.constructor = KnobInt;

KnobInt.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    this.raw_value = v/127.0;
    var range = this.max-this.min;
    this.int_value = Math.round((this.raw_value*range)+this.min);
    this.show();
    return 1;
  }
  return 0;
};

/* Encoder controller */
function Encoder(){
  Control.call(this);
  this.min = 0;
  this.max = 127;
  this.speed = 1.0;
}

Encoder.prototype = new Control();
Encoder.prototype.constructor = Encoder;

Encoder.prototype.handle = function(control,v) {
  if(control==this.cc_value){
    var direction = 1.0;
    var fixed_v = v;
    if(fixed_v>64){
      direction = -1.0;
      fixed_v -= 64;
    }
    this.raw_value += direction*this.speed*fixed_v/127.0;
    if(this.raw_value > 1.0)
      this.raw_value = 1.0;
    if(this.raw_value < 0.0)
      this.raw_value = 0.0;
    this.int_value = Math.round(((this.max-this.min)*this.raw_value)+this.min);
    if(this.int_value>this.max)
      this.int_value = this.max;
    if(this.int_value<this.min)
      this.int_value = this.min;
    this.show();
    return 1;
  }
  return 0;
};

/* ZeroSL control layer */

function ZeroSLControls(){
  this.controller = new ZeroSL();
  this.controls = [];
  this.controlHandler = null;
}

ZeroSLControls.prototype.open = function(device){
  this.controller.open(device);
  this.controller.setControlHandler(this);
  this.controller.clear();
};

ZeroSLControls.prototype.close = function() {
  controller.close();
};

ZeroSLControls.prototype.addControl = function(c){
  this.controls.push(c);
  c.show();
};

ZeroSLControls.prototype.handle = function(control,value) {
  for(var i=0;i<this.controls.length; i++){
    if(this.controls[i].enabled){
      if(this.controls[i].handle(control,value)!==0){
        if(this.controlHandler){
          this.controlHandler.handle(this.controls[i].name,this.controls[i].raw_value,this.controls[i].int_value);
        }
      }
    }
  }
};


ZeroSLControls.prototype.setControlValue = function(name,raw_value,int_value){
  for(var i=0; i<this.controls.length; i++){
    if(this.controls[i].name==name){
      this.controls[i].raw_value = raw_value;
      this.controls[i].int_value = int_value;
      this.controls[i].show();
    }
  }
};

ZeroSLControls.prototype.setControlEnable = function(name,on_off){
  for(var i=0; i<this.controls.length; i++){
    if(this.controls[i].name==name){
      this.controls[i].enabled=on_off;
      if(on_off) this.controls[i].show();
    }
  }
};

ZeroSLControls.prototype.setControlHandler = function(newHandler){
  this.controlHandler = newHandler;
};

/* Adds a push button with a Led visualizer */
ZeroSLControls.prototype.addPushLed = function(name,position)
{
  var push = new PushButton();
  var led = new Led();
  led.cc_value = position;
  led.controller = this.controller;
  push.name = name;
  push.cc_value = position;
  push.visualizers = [led];
  this.addControl(push);
};

/* Adds a toggle button with a Led visualizer */
ZeroSLControls.prototype.addToggleLed = function(name,position)
{
  var toggle = new ToggleButton();
  var led = new Led();
  led.cc_value = position;
  led.controller = this.controller;
  toggle.name = name;
  toggle.cc_value = position;
  toggle.visualizers = [led];
  this.addControl(toggle);
};

/* Adds a toggle button with a numeric visualizer */
ZeroSLControls.prototype.addToggleNumeric = function(name,position,lcd,column)
{
  var toggle = new ToggleButton();
  var num = new Numeric();
  var led = new Led();
  led.cc_value = position;
  led.controller = this.controller;
  num.lcd = lcd;
  num.column = column;
  num.label = name;
  num.controller = this.controller;
  toggle.name = name;
  toggle.cc_value = position;
  toggle.visualizers = [num, led];
  this.addControl(toggle);
};

/* Adds an encoder with a numeric visualizer */
ZeroSLControls.prototype.addEncoderNumeric = function(name,position,lcd, column,speed,min,max)
{
  var encoder = new Encoder();
  var num = new Numeric();
  var ring= new LedRing();
  ring.column = position-ZeroPos.Encoders;
  ring.controller = this.controller;
  num.lcd = lcd;
  num.column = column;
  num.label = name;
  num.min = min;
  num.max = max;
  num.controller = this.controller;
  encoder.name = name;
  encoder.cc_value = position;
  encoder.speed = speed;
  encoder.visualizers = [num, ring];
  this.addControl(encoder);
};

  /* Adds a knob with a numeric visualizer */
ZeroSLControls.prototype.addKnobNumeric = function(name,position,lcd,column,min,max)
{
  var knob = new Knob();
  var num = new Numeric();
  num.lcd = lcd;
  num.column = column;
  num.label = name;
  num.min = min;
  num.max = max;
  num.controller = this.controller;
  knob.name = name;
  knob.cc_value = position;
  knob.visualizers = [num];
  this.addControl(knob);
};

/* Adds a knob with a numeric visualizer */
ZeroSLControls.prototype.addKnobNumericInt = function(name,position,lcd,column,min,max)
{
  var knob = new KnobInt();
  var num = new Numeric();
  num.int_float = false;
  num.lcd = lcd;
  num.column = column;
  num.label = name;
  knob.min = min;
  knob.max = max;
  num.controller = this.controller;
  knob.name = name;
  knob.cc_value = position;
  knob.visualizers = [num];
  this.addControl(knob);
};

ZeroSLControls.prototype.addEncoderItems = function(name,position,lcd,column,speed,items)
{
  var encoder = new Encoder();
  var i = new Items();
  var ring = new LedRing();
  ring.column = position-ZeroPos.Encoders;
  ring.controller = this.controller;
  i.lcd = lcd;
  i.column = column;
  i.label = name;
  i.items = items;
  i.controller = this.controller;
  encoder.name = name;
  encoder.min = 0;
  encoder.max = items.length-1;
  encoder.speed = speed;
  encoder.cc_value = position;
  encoder.visualizers = [i,ring];
  this.addControl(encoder);
};

/* Adds a list of items controlled by a button */
ZeroSLControls.prototype.addCounterItems = function(name,position,lcd,column,items)
  {
    var counter = new CountButton();
    var i = new Items();
    var led = new Led();
    led.cc_value = position;
    led.controller = this.controller;
    i.lcd = lcd;
    i.column = column;
    i.label = name;
    i.items = items;
    i.controller = this.controller;
    counter.name = name;
    counter.min = 0;
    counter.max = items.length-1;
    counter.cc_value = position;
    counter.visualizers = [i,led];
    this.addControl(counter);
  };

module.exports = ZeroSLControls;