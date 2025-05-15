({
    doInit:function(component,event,helper){
        var action =component.get("c.getIsAuthenticated");
    var appName=component.get("v.appName");
    action.setParams({
        'appName':appName
    });
    action.setCallback(this,function(response){
 
        var responseVal=response.getReturnValue();
        console.log(response.getReturnValue());
        if((appName=='refresh' && responseVal.isSandbox && responseVal.isAuthenticated==true) ||
            (appName!='refresh' && responseVal.isAuthenticated==true)){
            var appEvent = $A.get("e.c:authSuccessEvent");
            appEvent.fire();
            //component.find("reset").set("v.disabled",false);
        }     
        component.set("v.appWrapper",responseVal);
        if(responseVal.libraryList.length>0 && responseVal.namedCredentialList.length>0){
            component.set("v.authCredentials.library_name__c",responseVal.libraryList[0].DeveloperName);
            component.set("v.authCredentials.named_credentials__c",responseVal.namedCredentialList[0]);
        }
        else{
            component.set("v.disabled",true);
            component.set("v.type",'error');
            component.set("v.message","No Named Credentials or Library found in the org.");
            $A.util.removeClass(component.find("message"),"slds-hide");
               }
        });
    $A.enqueueAction(action);
    },

    saveDetails : function(appName,component,helper) {
        component.set("v.disabled",true);
        var authCredentials=component.get("v.authSetting");
        var action =component.get("c.saveDetails");
        action.setParams({
            'authsetting':authCredentials,
            'appName':appName
        });
        action.setCallback(this,function(response){
            var toastEvent = $A.get("e.force:showToast");
            var resp=response.getReturnValue();
            console.log(resp);
            if(resp.success==false){
                if(toastEvent){
                    toastEvent.setParams({
                    "type":"error",
                    "title": "ERROR!",
                    "message": resp.message
                     });
                    toastEvent.fire();
                }
                else{
                    alert(resp.message);
                }
            }
            else{
                component.set("v.appWrapper.isAuthenticated",true);
                if(toastEvent){
                    toastEvent.setParams({
                    "type":"success",
                    "title": "Success!",
                    "message": "Settings saved."
                    });
                    toastEvent.fire();
                    }
                    else{
                        alert('Settings saved.');
                    }   
                var appEvent = $A.get("e.c:authSuccessEvent");
                appEvent.fire();
            }
            component.set("v.disabled",false);
       
         });
        $A.enqueueAction(action);
    }
})