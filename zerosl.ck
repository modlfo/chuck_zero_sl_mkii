// Chuck library for controlling the novation ZeroSL MKII 
// Author: Leonardo Laguna Ruiz
// e-mail: modlfo@gmail.com


public class ZeroSL
{
  MidiOut out;
  MidiMsg msg;

  // Send the first 3 messages of the header
  // Note: data1 in the following byte needs to be 0
  fun void sendHeader(){
    240 => msg.data1;
    0   => msg.data2;
    32  => msg.data3;
    out.send(msg);

    41  => msg.data1;
    3   => msg.data2;
    3   => msg.data3;
    out.send(msg);

    18  => msg.data1;
    0   => msg.data2;
    4   => msg.data3;
    out.send(msg);

  }
  fun void open(int device)
  {
    out.open(1);
    // Send connect message
    sendHeader();
    0   => msg.data1;
    1   => msg.data2;
    1   => msg.data3;
    out.send(msg);

    247 => msg.data1;
    0   => msg.data2; // the last two zeros are not part of the message
    0   => msg.data3;
    out.send(msg);
  }
  
  fun void close()
  {
    sendHeader();

    0   => msg.data1;
    1   => msg.data2;
    0   => msg.data3;
    out.send(msg);

    247 => msg.data1;
    0   => msg.data2; // the last two zeros are not part of the message
    0   => msg.data3;
    out.send(msg);
  }
  
  fun void clear(){
    sendHeader();

    0   => msg.data1;
    2   => msg.data2;
    2   => msg.data3;
    out.send(msg);

    1   => msg.data1;
    247 => msg.data2; 
    0   => msg.data3;
    out.send(msg);
  }

  fun void write(string s,int display,int position){
    0 => int i;
    0 => int byte_count;
    s.length() => int s_length;
    
    sendHeader();

    0   => msg.data1;
    2   => msg.data2;
    1   => msg.data3;
    out.send(msg);

    position   => msg.data1;
    display    => msg.data2;
    4   => msg.data3;
    out.send(msg);

    for(i;i<s_length;1 +=>i){
      s.charAt(i) => int c;
      if(byte_count==0)
        c => msg.data1;
      if(byte_count==1)
        c => msg.data2;
      if(byte_count==2){ // send every three bytes
        c => msg.data3;
        0 => byte_count;
        out.send(msg);
      } else {
        1 +=> byte_count;
      }
    }
    
    if(byte_count==0){
      247 => msg.data1;
      0   => msg.data2;
      0   => msg.data3;
      out.send(msg);
    }
    if(byte_count==1){
      247 => msg.data2;
      0   => msg.data3;
      out.send(msg);
    }
    if(byte_count==2){
      247 => msg.data3;
      out.send(msg);
    }
  }

}

