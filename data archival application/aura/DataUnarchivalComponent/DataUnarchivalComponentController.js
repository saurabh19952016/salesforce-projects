({
    findRecords : function(component, event, helper) {
        var fieldlist=component.get("v.selectedFields");
        if(component.get("v.Identifier")!=null && component.get("v.Identifier")!='' && fieldlist.length!=0){
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            helper.getArchived(component,event,helper);
            var columns=[];
            for(var i in fieldlist){
                columns.push({label: fieldlist[i], fieldName:  fieldlist[i], type: 'text'});
            }
            component.set('v.columns',columns);
        }
        else{
            component.set("v.message","Please fill the Record Id or Name and select required fields to Display.");
            component.set("v.type","error");
        }
    },
    	close : function(component, event, helper) {
		 component.set("v.message",null);
	},
    clearFields:function(component, event, helper) {
        component.set("v.fieldList",[]);
        component.set("v.objectName","");

    },
    handleFieldEvent:function(component,event,helper){
                component.set('v.columns',[]);

        component.set('v.selectedFields',[]);
        $A.util.toggleClass(component.find("spinner"),"slds-hide");
        var action=component.get("c.getFieldList");
        var object=component.get("v.objectName");
        console.log(object);
        action.setParams({
            "objectName":object
        });
        action.setCallback(this,function(response){
            console.log(response.getState());
            if(response.getState()=='SUCCESS'){
                console.log(response.getReturnValue());
                var fieldList=response.getReturnValue();
                var options=[];
                for(var i in fieldList){
                    options.push({'label': fieldList[i],'value':fieldList[i]});
                }
                component.set("v.fieldList",options);
            }
            $A.util.toggleClass(component.find("spinner"),"slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    
    unarchiveRecords:function(component,event,helper){
        helper.unarchiveRecords(component,event,helper);            
    }
    
})