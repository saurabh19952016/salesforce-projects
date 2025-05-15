({
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files")!=undefined) {
            helper.uploadHelper(component, event,helper);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    getConflicts:function(component,event,helper){
        if (component.find("fileId").get("v.files")!=undefined) {
            component.set("v.getConflict",true);
        helper.uploadHelper(component, event,helper);
    } else {
        alert('Please Select a Valid File');
    }
    },

    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

    handleMerge:function(component,event,helper){
        component.set("v.isOpen",false);
        component.set("v.disabled", true);
        helper.mergeAllHelper(component,event,helper);
    }
})