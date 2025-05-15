({
    /*handleEmails:function(component,event,helper){
        console.log("handlerEmail " +component.get("v.dateLimit"));
        var action = component.get(component.get("v.Method"));
        action.setParams({
            //"newDateTime":component.get("v.dateLimit"),
            "emIdList":component.get("v.emIdList")
        });
        
        action.setCallback(this,function(response) {
            console.log('response ' +response.getState());
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                   if(response.getReturnValue()!=null){
                    var emIdList=response.getReturnValue();
                    component.set("v.emIdList",emIdList);
                    console.log(component.get("v.emIdList"));    
                    helper.handleEmails(component,event,helper);
                    console.log("success");
                }
                else
                {
                    helper.handleError(component,event,response);    
                    console.log('Fail');
                }
            }
            else if (state === "ERROR") {
                // generic error handler
                helper.handleError(component,event,response);
            }
        });
        
        $A.enqueueAction(action);
    },*/
    
    handleAttachments:function(component,event,helper){
        var action = component.get(component.get("v.Method"));
        action.setParams({
            // "newDateTime":component.get("v.dateLimit"),
            "emIdList":component.get("v.emIdList")
        })
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") { 
                // pass returned value to callback function 
                var responsevalue=response.getReturnValue();
                
                if(response.getReturnValue()!=null ){
                    console.log(response.getReturnValue());
                    var emIdList=response.getReturnValue();
                    if(emIdList.length>0){
                        component.set("v.emIdList",emIdList);
                        helper.handleAttachments(component,event,helper);
                        console.log("success");                        
                    }
                    else{
                        console.log("End batch");
                    }
                    
                }
                else
                {
                    helper.handleError(component,event,response);    
                    console.log('Fail');
                }
            }
            else if (state === "ERROR") {
                // generic error handler
                helper.handleError(component,event,response);
            }
        });
        console.log("handler -- > " + new Date());
        
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