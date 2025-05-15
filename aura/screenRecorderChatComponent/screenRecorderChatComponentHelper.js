({
    MAX_FILE_SIZE: 25000000, //Max file size 25 MB 
    CHUNK_SIZE: 1000000,   
    
    processReply: function(component,event,helper){
        component.set("v.typing",true);
        
        var chatMetadata=  component.get("v.chatMetadata");
        if(chatMetadata.length>0){
            var currentText=component.get("v.currentText");
            var repliedTo=chatMetadata[currentText];
            var response=component.get("v.response");
            var reply=component.get("v.reply");
            if(repliedTo.fieldName__c!=undefined && repliedTo.Radio__c==false){
                if(component.get("v.apiName")!=null){
                    response[repliedTo.fieldName__c]=reply.Value;
                    reply=reply.Name;
                }
                else{
                    response[repliedTo.fieldName__c]=reply;
                } 
            }
            
            console.log(response);
            var params={
                "chatType":"outbound",
                "chatText":reply,
                "currentUser":component.get("v.currentUser")
            };
            helper.createChatElement(component,params);
            
            component.set("v.response",response); 
            component.set("v.currentText",currentText+1);                
            var newText=chatMetadata[currentText+1];
            params={
                "chatType":"inbound",
                "chatText":newText.Instructions__c,
                "Note":newText.Note__c,
                "radio":newText.Radio__c,
                "capture":newText.Capture__c,
                "optionRaw":newText.fieldName__c
            };
            helper.createChatElement(component,params);
            component.set("v.goBack",true);
            if(newText.SearchBox__c==true){
                component.set("v.apiName",newText.fieldName__c);
            }
            else{
                component.set("v.apiName",null);
            }
            if (newText.Capture__c==true || newText.Radio__c==true){
                component.set("v.disabled",true);
            }
            else{
                component.set("v.disabled",false);
            }
            component.set("v.reply",null);
            
        } 
        
    },
    
    createChatElement : function(component,params) {
        $A.createComponent(
            "c:chatElementComponent",
            params,
            function(chatElement, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(chatElement);
                    component.set("v.body", body);
                    component.set("v.typing",false);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );		
    },
    
    uploadHelper: function(component, event,helper) {
        // start/show the loading spinner   
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            component.set("v.disabled", false);
            return;
        }
        if (file.type != 'video/mp4') {
            component.set("v.fileName", 'Please upload a file in \'MP4\' format. The uploaded file format is ' + file.type );
            component.set("v.disabled", false);
            return;
        }
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,helper);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function(component, file, fileContents,helper) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',helper);
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,helper) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        helper.getPromise(
            component,
            helper,
            'c.saveChunk',
            {
                fileName: file.name,
                base64Data: encodeURIComponent(getchunk),
                contentType: file.type,
                fileId: attachId
            }
        ).then(function(response){
            startPosition = endPosition;
            endPosition = Math.min(fileContents.length, startPosition +helper.CHUNK_SIZE);
            
            if (startPosition < endPosition) {
                helper.uploadInChunk(component, file, fileContents, startPosition, endPosition, response,helper);
            } else {
                var params={
                    "chatType":"outbound", 
                    "chatText":file.name,
                    "isAttachment":true,
                    "currentUser":component.get("v.currentUser")
                };
                component.set("v.fileUpload",false);
                helper.createChatElement(component,params);
                var docIdList=component.get("v.docIds");
                docIdList.push(response);
                component.set("v.typing",true);
                component.set("v.docIds",docIdList);
                helper.sendToSnow(component,helper);
            }
        })
        .catch(function(error){
            if (error) {
                if (error[0] && error[0].message) {
                    var params={
                        "chatType":"delivery-failure",
                        "chatText":error[0].message
                    };
                    helper.createChatElement(component,params);
                }
            } else {
                var params={
                    "chatType":"delivery-failure",
                    "chatText":"Unknown error"
                };
                helper.createChatElement(component,params);
            }
        })
    },      
    
    sendToSnow : function(component,helper){
        var response=component.get('v.response');
        var currentText=component.get("v.currentText");
        var method='c.' + component.get("v.methodToCall");
        var docIds=component.get("v.docIds");
        helper.getPromise(
            component,
            helper,
            method,
            {
                "responseMap":response,
                "docIdList":docIds,
                "currentUser":component.get("v.currentUser")
            }
        ).then(function(response){
            
            var chatMetadata=  component.get("v.chatMetadata");
            if(docIds.length==0){
                var newText= chatMetadata[chatMetadata.length-1];
                newText.Instructions__c= newText.Instructions__c.replace('{!incidentNumber}',response);
                var params={
                    "chatType":"inbound",
                    "chatText":newText.Instructions__c,
                    "Note":newText.Note__c
                    
                };
                helper.createChatElement(component,params);
            }
            else{
                console.log('currentText'+currentText);
                chatMetadata.forEach(newText=>{
                    console.log(newText);
                    if(currentText<newText.order__c){
                    if(newText.Instructions__c.includes('{!incidentNumber}')){
                    
                    	newText.Instructions__c= newText.Instructions__c.replace('{!incidentNumber}',response);
                	}
                    var params={
                    "chatType":"inbound",
                    "chatText":newText.Instructions__c,
                    "Note":newText.Note__c
                    
                };
                helper.createChatElement(component,params);
            }
            
        });
    }
    
    component.set("v.chatMetadata",[]);
    
})
.catch(function(error){
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

}

})