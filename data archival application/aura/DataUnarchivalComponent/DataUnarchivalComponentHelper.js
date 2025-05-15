({
    
    getArchived : function(component,event,helper) {
        var action=component.get("c.getUnarchivedRecords");
        var Identifier=component.get("v.Identifier");
        var object= component.get("v.objectName");
        component.set("v.filteredEmails",[]);	
        action.setParams({
            "objectName":component.get("v.objectName"),
            "Identifier" : Identifier
        });
        console.log("handler")
        action.setCallback(this,function(response){
            console.log('new set --> ',response.getState());
            if(response.getState()=='SUCCESS'){
                var filteredRecords=[];
                var responseList=response.getReturnValue();
                if(responseList.length>0){
                    var rec;
                    for(var i in responseList){
                        console.log(responseList);
                        rec=JSON.parse(responseList[i]);
                        console.log(rec.Id,Identifier);
                        if(rec.Id.includes(Identifier)){
                            filteredRecords.push(rec);      
                        }
                        if(object=='Case' && rec.CaseNumber == Identifier){
                            filteredRecords.push(rec);
                        }
                        if(rec.Name==Identifier){
                            filteredRecords.push(rec);      
                        }
                        
                    }
                    console.log(filteredRecords);
                    //component.set("v.emList",JSON.parse(jsonList));
                    component.set("v.filteredRecords",filteredRecords);
                    //helper.getArchived(component,event,helper);
                }
                else
                    component.set("v.filteredRecords",[]);
            }
            else{
                helper.handleError(component,event,response);
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
        });
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
    
    unarchiveRecords:function(component,event,helper) {
        
        var selectedRows=component.find("dataTable").getSelectedRows();
        if(selectedRows.length!=0){
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
            var action=component.get("c.unarchiveRecordList");
            var object= component.get("v.objectName");
            console.log('test' +selectedRows);
            action.setParams({
                "objectName":component.get("v.objectName"),
                "selectedRowJSON" : JSON.stringify(selectedRows[0])
            });
            console.log("handler")
            action.setCallback(this,function(response){
                
                if(response.getState()=='SUCCESS'){
                    helper.getArchived(component,event,helper);
                    component.set("v.message","Record unarchived successfully.");
                    component.set("v.type","success");
                    component.set("v.filteredRecords",[]);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.message","Please select Record to unarchive.");
            component.set("v.type","error");
        }
    },
})