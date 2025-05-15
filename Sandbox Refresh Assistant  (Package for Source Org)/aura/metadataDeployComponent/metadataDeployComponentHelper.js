({
    MAX_FILE_SIZE: 25000000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

    getPromise:function(component,helper,actionName,params){
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get(actionName);
            action.setParams(params);
            action.setCallback(helper, function(actionResult) {
                if (actionResult.getState() === 'SUCCESS') {
                    resolve(actionResult.getReturnValue());
                } else {
                    let errors = actionResult.getError();
                    reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
                }
            });
            $A.enqueueAction(action);
        }));
    },   

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
            helper.uploadInChunk(component, helper,file, fileContents);
        });
 
        objFileReader.readAsDataURL(file);
    },
 

    uploadInChunk: function(component,helper, file, fileContents) {
        // call the apex method 'saveChunk'
        var action = component.get("c.saveFile");
        action.setParams({
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type
        });
        console.log('uploding');
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showLoadingSpinner", false);
                $A.util.toggleClass(component.find("message"),"slds-hide");
                $A.util.addClass(component.find("fileSection"),"slds-hide");
                component.set("v.message","Deployment Job has been submitted successfully");
                component.set("v.type","success");
                component.set("v.disabled", false);
                helper.loadMetadataList(component,helper);

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


    loadMetadataList: function(component,helper){
        var getMetadataJobIds=helper.getPromise(component,helper,'c.getMetadataJobIds',{operation:'deploy'});
        getMetadataJobIds.then(function(result){
        component.set("v.jobStatuses",result);
        console.log(result);
        $A.util.addClass(component.find("spinner"),'slds-hide'); 
        if(result.length>0){
                    helper.checkDeploy(component,helper);
        }
        });
    },

    checkDeploy:function(component,helper){
        console.log("Helper started");
        var promises=[];
        var jobWrapper=component.get("v.jobStatuses");
        if(jobWrapper.length>0){
        var checkJobDeploy=helper.getPromise(component,helper,'c.checkJobDeploy',{jobId:jobWrapper[0].jobId});
        checkJobDeploy.then(function(result){
            if(result.status=='Succeeded' || result.status=='Failed') {
                component.set("v.jobStatuses",[]);
            }
            else{
                component.set("v.deployResult",result);
                helper.checkDeploy(component,helper);
            }

        });
    }
      },


      cancelDeploymnent: function(component,event,helper){
        var jobWrapper=component.get("v.jobStatuses");
   
        var cancelDeploy=helper.getPromise(component,helper,'c.cancelDeployment',{jobId:jobWrapper[0].jobId});
        cancelDeploy.then(function(result){
            if(result.status=='Succeeded' || result.status=='Failed') {
                component.set("v.deployResult",null);
                component.set("v.jobStatuses",[]);
            }
            else{
                component.set("v.deployResult.status","Canceling");
            }

        });
      },


})