({
	doInit : function(component, event, helper) {
		helper.getSettings(component,event,helper);
	},
    clearBackup:function(component, event, helper) {
		var method=event.getSource().get("v.name");
		$A.util.toggleClass(component.find("spinner"),"slds-hide");
		$A.util.addClass(component.find("message"),"slds-hide");
		var action = component.get("c.deleteSavedData");
		action.setParams({
			'objects':method
		});
		action.setCallback(this, function(response) {
			if(response.getReturnValue()!='Success'){
				$A.util.removeClass(component.find("message"),"slds-hide");
				component.set("v.message",response.getReturnValue());
				component.set("v.type",'error');
			}
			helper.getSettings(component,method,helper);
		});
		$A.enqueueAction(action);
	},
})