

public class Venom
{
  MidiOut mout;

  fun void open(int device)
  {
    if( !mout.open(device) ) me.exit();
  }

   /* ---------   OSCILLATORS ---------------*/

  fun void setOscDrift(int drift)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x14,0x00,drift,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setOSCStartMod(int val)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x13,0x00,val,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }
  fun void setOSCRingMod(int val)
  {
    RawMidiSender.sendControl(51,val,mout);
  }
  //------ Osc 1
  fun void setOsc1Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x1A,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc1Coarse(int level)
  {
    RawMidiSender.sendControl(29,level,mout);
  }

  fun void setOsc1Fine(int level)
  {
    RawMidiSender.sendControl(61,level,mout);
  }

  fun void setOsc1KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0x62,0x65,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOcs1To3FM(int val)
  {
    RawMidiSender.sendControl(50,val,mout);
  }

  fun void setOcs1WaveShape(int val)
  {
    RawMidiSender.sendControl(49,val,mout);
  }

  //------- Osc 2
  fun void setOsc2Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x1D,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc2Coarse(int level)
  {
    RawMidiSender.sendControl(30,level,mout);
  }

  fun void setOsc2Fine(int level)
  {
    RawMidiSender.sendControl(62,level,mout);
  }

  fun void setOsc2KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0x62,0x66,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc2Sync(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x40 => val;
    else
      0x3F => val;
    [0xB0,0x63,0x02,0x62,0x7D,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  //------- Osc 3
  fun void setOsc1Wave(int wave)
  {
    [0xF0,0x00,0x01,0x05,0x21,0x00,0x02,0x09,0x00,0x21,0x00,wave,0xF7] @=> int msg[];
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc3Coarse(int level)
  {
    RawMidiSender.sendControl(31,level,mout);
  }

  fun void setOsc3Fine(int level)
  {
    RawMidiSender.sendControl(63,level,mout);
  }

  fun void setOsc3KeyTrack(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x3F => val;
    else
      0x40 => val;
    [0xB0,0x63,0x02,0x62,0x67,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  fun void setOsc3Sync(int on_off)
  {
    int msg[];
    int val;
    if(on_off!=0)
      0x40 => val;
    else
      0x3F => val;
    [0xB0,0x63,0x02,0x62,0x7E,0x06,val] @=> msg;
    RawMidiSender.send(msg,mout);
  }

  // ----- Mix

  fun void setOsc1Level(int level)
  {
    RawMidiSender.sendControl(56,level,mout);
  }

  fun void setOsc2Level(int level)
  {
    RawMidiSender.sendControl(57,level,mout);
  }

  fun void setOsc3Level(int level)
  {
    RawMidiSender.sendControl(58,level,mout);
  }

  fun void setExtLevel(int level)
  {
    RawMidiSender.sendControl(54,level,mout);
  }

  fun void setExtSource(int val)
  {
    if(val>6)
    {
      <<<"setExtSource value is larger than 6">>>;
      6 => val;
    }
    RawMidiSender.sendControl(55,val,mout);
  }

  /// ---- Pitch
  fun void setGlide(int on_off)
  {
    if(on_off!=0)
    {
      RawMidiSender.sendControl(65,75,mout);
    }
    else
    {
      RawMidiSender.sendControl(65,31,mout);
    }
  }
  fun void setGlideRange(int val)
  {
    RawMidiSender.sendControl(5,val,mout);
  }
  fun void setBendRange(int val)
  {
    RawMidiSender.sendControl(60,val,mout);
  }
}