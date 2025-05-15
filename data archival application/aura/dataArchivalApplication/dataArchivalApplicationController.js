({
	close : function(component, event, helper) {
		$A.util.toggleClass(component.find("alert"),"slds-hide");
	}
})