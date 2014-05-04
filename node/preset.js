var fs = require('fs');

Preset = function(){
	this.handler = null;
	this.current = {};
};

Preset.prototype.sendParameters = function(obj) {
	for(var name in this.current){
		var name_repl = name.replace('_',' ');
		var params = this.current[name];
		var raw_value = params['raw_value'];
		var value = params['value'];
		obj.update_controls = 1;
		obj.handle(name_repl,params['raw_value'],params['value']);
		obj.update_controls = 0;
		//console.log('Sending ',name_repl,params['raw_value'],params['value']);
	}
};

Preset.prototype.setValue = function(key,raw_value,value) {
  var skey = key.replace(' ','_');
  this.current[skey] = { 'raw_value' : raw_value, 'value' : value };  
};

Preset.prototype.saveToFile = function(file) {
	var str = JSON.stringify(this.current);
	fs.writeFile(file, str, function(err) {
    	if(err) {
    	    console.log(err);
    	} else {
    	    //console.log(str);
    	}
	}); 
};

Preset.prototype.setCurrent = function(obj) {
	this.current = obj;
};

Preset.prototype.readFromFile = function(file,obj) {
	var that = this;
	console.log('Reading file');
	fs.readFile(file,function (err, data) {
  		if (err) throw err;
		str = JSON.parse(data);
		that.setCurrent(str);
		console.log('Reading done');
		that.sendParameters(obj);
	});
};

module.exports = Preset;