

public class MemoryMap {
	ZeroSLTopHandler handler;
	int values[0];
	float raw_values[0];
	int keys[0];
	string keys_iter[0];

	fun void setParameterHandler(ZeroSLTopHandler new_handler){
		new_handler @=> handler;
	}

	fun void sendParameters(){
		keys_iter.size() => int size;
			for(0=>int i;i<size;i+1=>i){
				if(keys_iter[i].length()!=0){
					handler.handle(keys_iter[i],raw_values[keys_iter[i]],values[keys_iter[i]]);
				}
			}
	}
	fun void setValue(string key_,float raw_value,int value){
		key_ => string key; // for some weird reason if I don't do this key has a empty string
		if(key.length()!=0){
			if(keys[key]==0){ // the key does not exists insert it
				1 => keys[key];
				keys_iter << key;
			}
			value => values[key];
			raw_value => raw_values[key];
			//<<<"Setting ",key,keys[key],raw_values[key],values[key]>>>;
		}
	}

	fun void saveToFile(string file){
		FileIO fout;
		fout.open(file, FileIO.WRITE );
		if(fout.good()){
			keys_iter.size() => int size;
			for(0=>int i;i<size;i+1=>i){
				if(keys_iter[i].length()!=0){
					fout <= keys_iter[i] <= IO.newline();
					fout <= raw_values[keys_iter[i]] <= IO.newline();
					fout <= values[keys_iter[i]] <= IO.newline();
				}
			}
			fout.close();
		}
	}
	fun void readFromFile(string file){
		FileIO fio;
		fio.open(file, FileIO.READ );
		if(fio.good()){
			0 => int count;
			"" => string key;
			0 => int value;
			0.0 => float raw_value;
			while( fio.more() ){
				fio.readLine() => string val;
				if(count==0){
					val.trim() => key;
					count+1=>count;
				}
				else if(count==1){
					Std.atof(val) => raw_value;
					count+1=>count;
				}
				else if(count==2){
					Std.atoi(val) => value;
					0=>count;
					if(key.length()!=0)
					{
						setValue(key,raw_value,value);
					}
				}
				else
					0=>count;
			}
			fio.close();
		}
	}
}