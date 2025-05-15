({
	inithelper : function(component,event,helper) {
		        var action=component.get("c.getSetupRequired");
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                console.log('setup required-' +response.getReturnValue());
                component.set("v.setup",response.getReturnValue().length>0?false:true);
            }
        });
        $A.enqueueAction(action);
	},
    
    setupArchival:function(component,helper){
           var action=component.get("c.createSetupForArchival");
        action.setCallback(this,function(response){
            var toastEvent = $A.get("e.force:showToast");
            
            if(response.getState()=='SUCCESS'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type":"success"
                });
            }
            else{
                let errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                     toastEvent.setParams({
                    "title": "ERROR",
                    "message": errors[0].message,
                    "type":"error" 
                    
                });
                }
               
            }
        });
        $A.enqueueAction(action);
        
    }
})