({
	getPromise : function(component, helper, actionName, params){
		   return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get(actionName);
            action.setParams(params);
            action.setCallback(helper, function(actionResult) {
                if (actionResult.getState() === 'SUCCESS') {
                    resolve(actionResult.getReturnValue());
                } else {
                    let errors = actionResult.getError();
                    reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
                }
            });
            $A.enqueueAction(action);
        }));
	},
    
      showToast: function(title,message,type){
      var showToast= $A.get("e.force:showToast");
            showToast.setParams({
                title:title,
                message:message,
                type	:type
            })
            showToast.fire();  
}
    
})