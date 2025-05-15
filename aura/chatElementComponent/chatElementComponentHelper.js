({
    handleRecord :function(component,event,helper,response){
        component.set('v.traceFlagId',response);
        var name=event.getSource().get("v.name");
        var captureEvt=$A.get("e.c:captureLogEvent");
        captureEvt.setParams({
            'operation':name,
            'action':"start"
        });
        captureEvt.fire();
        console.log(captureEvt);
        console.log(component.get("v.responseList"));
        component.set("v.btnName",name);
        component.set("v.started",true);
        window.setTimeout(
            $A.getCallback(function() {
                if(component.get("v.capture")==true){
                 helper.stopCaptureHelper(component,event,helper);
                  
                }
            }), 180000
        );
    },
    
    stopCaptureHelper: function(component,event,helper){
               helper.getPromise(
            component,
            helper,
            'c.getDebugLogs',
            {'TraceFlagId':component.get("v.traceFlagId")}
        ).then(function(response){
            helper.handleStop(component,helper,event,response);
            
        })
    },
    
    handleStop :function(component,helper,event,response){
        component.set("v.capture",false);
        var name=component.get("v.btnName");
        if(name=='recordScreen'){
            var captureEvt=$A.get("e.c:captureLogEvent");
            captureEvt.setParams({
                'operation':name,
                'action':"stopCapture"
            });
            captureEvt.fire();
        }
        
        var PromiseList=[];
        response.forEach(logId=>{
            PromiseList.push(helper.getPromise(  component,helper,'c.getLogBody',{'LogId':logId}));
    });
    Promise.all(PromiseList).then($A.getCallback(function(value){
    var captureEvt2=$A.get("e.c:captureLogEvent");
    captureEvt2.setParams({
    'operation':name,
    'action':"stop",
    'docIds':value
});
captureEvt2.fire();

}));
}
})