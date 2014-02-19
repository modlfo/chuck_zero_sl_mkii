// Chuck library for controlling the novation ZeroSL MKII
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com
//  Notes: this library requires patching rtmidi.cpp the function
//         RtMidiOut :: sendMessage
//          if ( result < (int)nBytes && false) {
//             errorString_ = "RtMidiOut::sendMessage: event parsing error!";


public class ZeroSL
{
  MidiOut mout;
  RawMidiSender sender;

  // enumerations
  0 => int LeftLCD;
  1 => int RigthLCD;

  1 => int Row1;
  2 => int Row2;

  fun void open(int device)
  {
    if( !mout.open(device) ) me.exit();
    <<< mout.name(), "is open!" >>>;
    // Send connect message
    [240,0,32,41,3,3,18,0,4,0,1,1,247] @=> int connect_msg[];
    sender.send(connect_msg,mout);
  }

  fun void close()
  {
    [240,0,32,41,3,3,18,0,4,0,1,0,247] @=> int disconnect_msg[];

    sender.send(disconnect_msg,mout);
  }

  fun void clear(){
    [240,0,32,41,3,3,18,0,4,0,2,2,1,247] @=> int clear_msg[];

    sender.send(clear_msg,mout);

  }

  fun void writeLabel(string s, int left_right, int row, int column)
  {
    0 => int display;
    0 => int position;
    "" => string str;
    if(left_right==0 && row == 1)
      1 => display;
    if(left_right==1 && row == 1)
      2 => display;
    if(left_right==0 && row == 2)
      3 => display;
    if(left_right==1 && row == 2)
      4 => display;
    // crop the string if larger than 8
    if(s.length()>=8)
      s.substring(0, 8) => str;
    else
      s => str;
    write(str,display,(column-1)*9);
  }

  fun void writeIntLabel(int i, int left_right, int row, int column ){
    writeLabel(Std.itoa(i),left_right,row,column);
  }

  fun void writeFloatLabel(float i, int left_right, int row, int column ){
    writeLabel(Std.ftoa(i,8),left_right,row,column);
  }

  fun void write(string s, int display, int position){
    [240,0,32,41,3,3,18,0,4,0,2,1,position,display,4] @=> int msg[];
    0 => int i;
    s.length() => int s_length;
    // append the characters to the array
    for(i;i<s_length;1 +=>i){
      msg<<s.charAt(i);
    }
    msg<<247; // finalize the message
    sender.send(msg,mout);
  }

  fun void setLedRing(int ring, int value){
    MidiMsg msg;
    176        => msg.data1;
    112+ring   => msg.data2;
    value      => msg.data3;
    mout.send(msg);
  }
}



