

// Base class for value visualizers
class Visualizer
{
  0      => int visible;
  "None" => string label;
  0.0    => float value;

  MidiOut mout;

  fun void update(float v){
    <<< "Empty visualizer" >>>;
  }
}

// Base class for controls
class Control
{
  0.0   => float min;
  127.0 => float max;
  0.0   => float value;
  "default" => string name;

  Visualizer visualizer;

  fun void handle(int control, int value)
  {
    <<< "Empty handler for control :", name >>>;
  }
}

// LED visualizer, used to turn on/off a button in the controller
class LED extends Visualizer
{
  0 => int cc_value;
  fun void update(float v){
    MidiMsg msg;
    176      => msg.data1;
    cc_value => msg.data1;
    if(v==0)
      0 => msg.data1;
    else
      1 => msg.data1;
    mout.send(msg);
  }
}

class ToggleButton extends Control
{
  0 => int cc_value;
  fun void handle(int control,int v)
  {
    if(control == cc_value)
    {
       if(v!=0)
       {
          if(value!=0.0)
            0.0 => value;
          else
            1.0 => value;
       }
       visualizer.update(value);
    }
  }
}


public class ZeroSLTop extends ZeroSLHandler
{
  ZeroSL controller;
  Control controls[];

  fun void open(int device)
  {
    controller.open(device);
    controller.setControlHandler(this);
    controller.clear();
  }

  fun void close()
  {
    controller.close();
  }

  fun void handle(int control,int value)
    {
      <<< "control ",control," value ",value >>>;
      if(controls!=null)
      {
        controls.size() => int size;
        for(0=>int i;i<size;1+=>i)
        {
          controls[i].handle(control,value);
        }
      }
    }


}