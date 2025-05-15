({
	uploadCSV : function(component,helper,csv) {
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
         var action=component.get("c.importCSVFile");
        action.setParams({
            "csvAsString":csv,
            "metadata":component.get("v.selected")
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                var messageList=response.getReturnValue();
                if(messageList.includes($A.get("{!$Label.c.meta_act_successful}"))){
                    component.set("v.messageType","info");
                    component.set("v.Title","Information");
                }
                else
                {
                    component.set("v.messageType","error");
                    component.set("v.Title","Error");
                } 
                component.set("v.MessageList",messageList);
                        $A.util.toggleClass(component.find("spinner"),"slds-hide");

            }
        });
        $A.enqueueAction(action);
		
	}
})