({
    doInit : function(component, event, helper) {
        helper.getPromise(
            component,
            helper,
            'c.startRequest',
            {}
        ).then(function(response){
            if(response.isLogDeletion){
                throw $A.get("$Label.c.apex_log_deletion_notification");
            }
            if(response.isTraceFlagDeletion){
                throw $A.get("$Label.c.trace_flag_deletion_notification");
            }
                else{
                    component.set("v.currentText",0);
                    component.set("v.chatStarted",true);
                    var currentUser=response.currentUser;
                    var metadataList=response.metaList;
                    if(metadataList[0].Instructions__c.includes('{!fullName}')){
                         metadataList[0].Instructions__c=metadataList[0].Instructions__c.replace('{!fullName}',currentUser.Name);
                    }
                    var params={
                        "chatType":"inbound",
                        "chatText":metadataList[0].Instructions__c,
                        "Note":metadataList[0].Note__c
                    };
                    helper.createChatElement(component,params);
                    component.set("v.chatMetadata",metadataList);
                    component.set("v.currentUser",currentUser);
                }
        })
        .catch(function(error){
            component.set("v.disabled",true);
            if (error) {
                var params={
                    "chatType":"delivery-failure",
                    "chatText":error
                };
                helper.createChatElement(component,params);
            } else {
                var params={
                    "chatType":"delivery-failure",
                    "chatText":"Unknown error"
                };
                helper.createChatElement(component,params);}
            component.set("v.chatMetadata",[]);
        }) 
    },
    
    sendAction: function(component,event,helper){
        helper.processReply(component,event,helper);
    },
    
    handleEvent :  function(component,event,helper){
        component.set("v.typing",true);
        component.set("v.goBack",false);
        if(event.getParam("action")!='stopCapture'){
            var currentText=component.get("v.currentText");
            var chatMetadata=  component.get("v.chatMetadata");
            
            var newText=chatMetadata[currentText+1];
            component.set("v.currentText",currentText+1);  
            component.set("v.disabled",true);
            var params={
                "chatType":"inbound",
                "chatText":newText.Instructions__c,
                "Note":newText.Note__c
            };
            if(event.getParam("action")=='start'){
                helper.createChatElement(component,params);
                component.set("v.typing",true);
            }
            else if(event.getParam("action")=='stop' && event.getParam("operation")=='recordScreen'){
                component.set("v.fileUpload",true);
                component.set("v.docIds",event.getParam("docIds"));
                helper.createChatElement(component,params);
                component.set("v.disabled",false);
            }
                else if(event.getParam("action")=='stop' && event.getParam("operation")=='logOnly'){
                    component.set("v.docIds",event.getParam("docIds"));
                    helper.sendToSnow(component,helper);
                }
                    else if(event.getParam("operation")=='createOnly'){
                        helper.sendToSnow(component,helper);
                        
                    }
        }
    },
    
    goBack: function(component,event,helper){
        var chatMetadata=  component.get("v.chatMetadata");
        if(chatMetadata.length>0){
            var currentText=component.get("v.currentText");
            var newText=chatMetadata[currentText-1];
            var params={
                "chatType":"inbound",
                "chatText":newText.Instructions__c,
                "Note":newText.Note__c,
                "radio":newText.Radio__c,
                "capture":newText.Capture__c,
                "optionRaw":newText.fieldName__c
            };
            helper.createChatElement(component,params);      
            component.set("v.currentText",currentText-1);
            if(newText.SearchBox__c==true){
                component.set("v.apiName",newText.fieldName__c);
            }
            else{
                component.set("v.apiName",null);
            }
            if (newText.Capture__c==true){
                component.set("v.disabled",true);
            }
            else{
                component.set("v.disabled",false);
            }
            if(currentText-1==0){
                component.set("v.goBack",false);
            }
        }
    },
    
    handleFilesChange : function(component,event,helper){
        component.set("v.currentText",component.get("v.currentText")+1);
        component.set("v.typing",true);
        component.set("v.disabled",true);
        helper.uploadHelper(component, event,helper);
    },
    
    handleRadioSelect : function(component,event,helper){
        var destination=event.getParam("methodToCall");
        var buttonName=event.getParam("buttonName");
        component.set("v.methodToCall",destination);
        console.log('destination--'+ destination);
        if(destination=='sendToSnow'){
            component.set("v.reply",'Create ticket in ' +buttonName);
        }
        else{
            component.set("v.reply",'Create Case in ' + buttonName);
        }
        helper.processReply(component,event,helper);
    }
    
})