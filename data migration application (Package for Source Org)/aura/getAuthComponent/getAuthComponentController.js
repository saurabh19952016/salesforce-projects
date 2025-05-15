({
doInit : function(component, event, helper) {
    if($A.get("e.force:navigateToURL")==undefined){
        component.set("v.isStandalone",true);
    }
    helper.doInit(component,event,helper);
},



saveSetting:function(component,event,helper){
    
    $A.util.addClass(component.find("message"),"slds-hide");
    var authCredentials=component.get("v.authSetting");
    var appName=component.get("v.appName");
    var error=false;

    var message='';
        if(authCredentials.named_credentials__c==undefined || authCredentials.named_credentials__c==''){
        message="Please enter Named Credential API Name.<br/>";
        error=true;
    }

    else  if(appName=='refresh' && (authCredentials.library_name__c==undefined || authCredentials.library_name__c=='')){
        message="Please enter Library Name.<br/>";
        error=true;
    }
    if(error==true){
        component.set("v.type",'error');
        component.set("v.message",message);
        $A.util.removeClass(component.find("message"),"slds-hide");
    }

    else{
    authCredentials.endpoint__c=component.get("v.value");
    helper.saveDetails(appName,component,helper);
    console.log('inside helper');
    }
            
    },
    openNamedCredentialTab:function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": event.getSource().get("v.name")
        });
        urlEvent.fire();
    }
})