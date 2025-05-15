({
    
    getArchived : function(component,event,helper) {
       var action=component.get("c.unarchiveEmailMessages");
       var caseNumber=component.get("v.caseNumber");
       component.set("v.filteredEmails",[]);	
        action.setParams({
            "caseNumber" : caseNumber
        });
        console.log("handler")
        action.setCallback(this,function(response){
            console.log('new set --> ',response.getState());
            if(response.getState()=='SUCCESS'){
                var filteredEmails=[];
                var responseList=response.getReturnValue();
                if(responseList!=null){
                    var emrec;
                    for(var i in responseList){
                        emrec=JSON.parse(responseList[i]);
                        if(emrec.Parent.CaseNumber == caseNumber){
                            filteredEmails.push(emrec);
                        }
                    }
                    //component.set("v.emList",JSON.parse(jsonList));
                    component.set("v.filteredEmails",filteredEmails);
                    //helper.getArchived(component,event,helper);
                }
            }
            else{
                helper.handleError(component,event,response);
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        });
        $A.enqueueAction(action);
    },  
    handleError:function(component,event,response) {
        var errors = response.getError();
        if (errors) {
            //console.log("Errors", errors);
            console.log("Retrieving Attachments from Email Messages failed.",errors);
        } else {
            console.log("Unknown Error");
        }
        component.set("v.Status","Failed");
    },
})