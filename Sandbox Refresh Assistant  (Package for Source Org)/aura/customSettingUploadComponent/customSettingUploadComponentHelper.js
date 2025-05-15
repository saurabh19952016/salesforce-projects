({
    MAX_FILE_SIZE: 25000000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event,helper) {
        // start/show the loading spinner   
        component.set("v.disabled", true);
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            component.set("v.disabled", false);
            return;
        }
        if (file.type != 'application/x-zip-compressed') {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Please upload a file in \'application/x-zip-compressed\' format. The uploaded file format is ' + file.type );
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
            if(component.get("v.getConflict")){
                helper.uploadForConflicts(component, file, fileContents);
               
            }
            else{
                helper.uploadInChunk(component, file, fileContents);
            }
        });
 
        objFileReader.readAsDataURL(file);
    },
 
 
    uploadForConflicts:function(component,file,fileContents){
        var action = component.get("c.getFileNames");
        action.setParams({
            base64Data: encodeURIComponent(fileContents)
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var state = response.getState();
            if (state === "SUCCESS") {    
                var fileNames=response.getReturnValue();
                component.set("v.customSettingList",fileNames);
                component.set("v.showLoadingSpinner",false);
                component.set("v.isOpen",true);
                component.set("v.disabled", false);
                component.set("v.getConflict",false);
    
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    uploadInChunk: function(component, file, fileContents) {
        // call the apex method 'saveChunk'
        var action = component.get("c.saveFile");
        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showLoadingSpinner", false);
                $A.util.toggleClass(component.find("message"),"slds-hide");
                $A.util.addClass(component.find("fileSection"),"slds-hide");
                component.set("v.message","Job has been submitted successfully");
                component.set("v.type","success");
                component.set("v.disabled", false);

            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    mergeAllHelper: function(component,event,helper){
        let action = component.get("c.mergeAllSettings");

        action.setParams({
            settingsList:event.getParam("settingsList")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                $A.util.toggleClass(component.find("message"),"slds-hide");
                $A.util.addClass(component.find("fileSection"),"slds-hide");
                component.set("v.message","Job has been submitted successfully");
                component.set("v.type","success");
                component.set("v.disabled", false);
            }
            else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } 
        });
        $A.enqueueAction(action);
    }
})