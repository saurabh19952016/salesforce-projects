({
    doInit : function(component, event, helper) {
        var action=component.get("c.getMetadataValues");
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set("v.metadataList",response.getReturnValue());
                component.set("v.selected",response.getReturnValue()[0]);
            }
        });
        $A.enqueueAction(action);
    },
    
    uploadFile:function(component,event,helper){
        if (component.find("fileId").get("v.files") !=null ) {
            var fileInput = component.find("fileId").get("v.files");
            console.log(fileInput);
            var file = fileInput[0];
            if (file) {
                console.log("File");
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    console.log("EVT FN");
                    var csv = evt.target.result;
                    console.log('@@@ csv file contains'+ csv);
					helper.uploadCSV(component,helper,csv);                    
                }
                reader.onerror = function (evt) {
                    console.log("error reading file");
                }
            }
            
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
    
})