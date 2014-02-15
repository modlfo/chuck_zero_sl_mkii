// Chuck library for controlling the novation ZeroSL MKII 
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com
//  Notes: this library requires patching rtmidi.cpp the function
//         RtMidiOut :: sendMessage
//          if ( result < (int)nBytes && false) {
//             errorString_ = "RtMidiOut::sendMessage: event parsing error!";
    

public class ZeroSL
{
  MidiOut out;
  RawMidiSender sender;
    
  fun void open(int device)
  {
    if( !out.open(device) ) me.exit();
    <<< out.name(), "is open!" >>>;  
    // Send connect message  
    [240,0,32,41,3,3,18,0,4,0,1,1,247] @=> int connect_msg[];  
    sender.send(connect_msg,out);
  }
  
  fun void close()
  {
    [240,0,32,41,3,3,18,0,4,0,1,0,247] @=> int disconnect_msg[]; 

    sender.send(disconnect_msg,out);
  }
  
  fun void clear(){
    [240,0,32,41,3,3,18,0,4,0,2,2,1,247] @=> int clear_msg[]; 

    sender.send(clear_msg,out);

  }

  fun void write(string s,int display,int position){
    [240,0,32,41,3,3,18,0,4,0,2,1,position,display,4] @=> int msg[];
    0 => int i;
    s.length() => int s_length;
    // append the characters to the array
    for(i;i<s_length;1 +=>i){
      msg<<s.charAt(i);
    }
    msg<<247; // finalize the message
    sender.send(msg,out);
  }
 
  fun void setLedRing(int ring, int value){
    176        => msg.data1;
    112+ring   => msg.data2;
    value      => msg.data3;
    mout.send(msg);
  }
}

  
