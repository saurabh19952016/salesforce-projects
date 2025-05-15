({
	doInit : function(component, event, helper) {
		var action = component.get("c.getDownloadHistory");
		action.setCallback(this, function(response) {
		   var state = response.getState();
		   if(component.isValid() && state === 'SUCCESS') {
		       component.set("v.items", response.getReturnValue()); 
		   }
		});
		$A.enqueueAction(action);
        
	},
    
})