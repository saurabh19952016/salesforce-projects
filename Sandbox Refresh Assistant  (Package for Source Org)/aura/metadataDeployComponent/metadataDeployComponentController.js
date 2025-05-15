({
    doInit : function(component, event, helper) {
        console.log("Inside CSide Cont"); 
        helper.loadMetadataList(component,helper);
    },
    
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files")!=undefined) {
            helper.uploadHelper(component, event,helper);
        } else {
            alert('Please Select a Valid File');
        }
    },
    

    cancelDeploy: function(component, event, helper) {
            helper.cancelDeploymnent(component,event,helper);
    },

    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

})