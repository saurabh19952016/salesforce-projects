({
    doInit :function(component,event,helper){
        var datetime = new Date();
        var time=datetime.getHours() + ':';
        var mins=datetime.getMinutes();
        if(mins<10){
            time+='0'+mins;
        }
        else{
            time+=mins;
        }
        if(datetime.getHours()>12){
            time+= ' PM';
        }
        else{
            time+=' AM';
        }
        component.set("v.time",time);
        if(component.get("v.radio")==true){
            console.log(component.get("v.optionRaw"));
            var optionRaw=JSON.parse(component.get("v.optionRaw"));
            var options=[];
            for(var key in optionRaw){
                
                if (key=='Salesforce') {
                    options.push({label :optionRaw[key],value:'createCase'});
                }
                else if(key=='Target'){
                    options.push({label : optionRaw[key],value:'sendToSnow'});
                }
            }
        component.set("v.options",options);
        }
    },
    captureLogs : function(component, event, helper) {
        helper.getPromise(
            component,
            helper,
            'c.setTraceFlag',
            {}
        ).then(function(response){
            helper.handleRecord(component,event,helper,response);
        })
    },
    
    stopCapture : function(component, event, helper) {
        helper.stopCaptureHelper(component, event, helper);
        
    },
    
    createCase : function(component, event, helper) {
        var captureEvt=$A.get("e.c:captureLogEvent");
        captureEvt.setParams({
            'operation':"createOnly",
        });
        captureEvt.fire();
        component.set("v.capture",false);
    },
    
    handleRadioChange: function(component, event, helper) {
        var captureEvt=component.getEvent("radioSelectEvent");
        var value=event.getSource().get("v.value");
        var options=component.get("v.options");
        var buttonName='';
        for(var opt in options){
            if(options[opt].value==value){
                buttonName=options[opt].label;
                break;
            }
        }
        captureEvt.setParams({
            'methodToCall':value,
            'buttonName':buttonName
        });
        captureEvt.fire();
        component.set("v.radio",false);
    },
})