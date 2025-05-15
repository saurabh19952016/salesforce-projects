({
    getSettings : function(component,event,helper) {
		$A.util.removeClass(component.find("spinner"),"slds-hide");
		var action = component.get("c.getSaved");
		action.setParams({
			isMetadata:component.get("v.isMetadata")
		})
		action.setCallback(this, function(response) {
			$A.util.addClass(component.find("spinner"),"slds-hide");
			var state = response.getState();
		   if(state === 'SUCCESS') {
			   var returnObj=response.getReturnValue();
			   component.set("v.items", returnObj.docList); 
			   
			   component.set("v.targetBaseUrl",returnObj.downloadResourceURL);
			   if(returnObj.isSizeExceeded){
				$A.util.removeClass(component.find("message"),"slds-hide");
				component.set("v.message","File Storage has exceeded the limit of 1 GB in the backup storage org. Please delete existing files to continue taking backups.");
				component.set("v.type",'error');
			   }
			   var appEvent=$A.get("e.c:fileSizeEvent");
			   appEvent.setParams({
				   "isSizeExceeded":returnObj.isSizeExceeded
			   })
			   appEvent.fire();
			}
		   else{
			$A.util.removeClass(component.find("message"),"slds-hide");
			component.set("v.message",'An error occured while getting files from remote org.');
			component.set("v.type",'error');
		   }
		});
		$A.enqueueAction(action);
    }
})