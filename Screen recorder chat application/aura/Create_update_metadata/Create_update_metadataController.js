({
    init : function(component, event, helper) {
        let columns = [
            { label: 'order', fieldName: 'order', type: 'number',editable:true,  typeAttributes: { minimumFractionDigits:0 } },
            { label: 'Instructions', fieldName: 'Instruction', type: 'text',editable:true },
            { label: 'Sfdc Field/ Button Name', fieldName: 'SfdcFieldName', type: 'text',editable:true },
            { label: 'Target Field/ Button Name', fieldName: 'TargetFieldName', type: 'text',editable:true },
            { label: 'Note', fieldName: 'Note', type: 'text',editable:true  },
            { label: 'Environment Selection', fieldName: 'Radio', type: 'boolean',editable:true},
            { label: 'Group Selection', fieldName: 'SearchBox', type: 'boolean',editable:true},
            { label: 'Screen Capture Option', fieldName: 'Capture', type: 'boolean',editable:true }
            
        ];	
        // set the column on component
        component.set( "v.columns", columns );
        
        
        // Get the data from server side action
        helper.fetchData( component,helper);
        
    },
    
    
    addRows: function(component, event, helper) {
        var allList=component.get("v.data");
        allList.push(
            {id:allList.length+1,
             order:'',
             Instructions:'',
             SfdcFieldName:'',
             TargetFieldName:'',
             Note:'',
             Radio:'',
             SearchBox:'',
             Capture:''
            }
        );
        component.set("v.data",allList);
    },
    
    
    
    handleSave: function(component, event, helper) {

           helper.validateRecords(component,event.getParam('draftValues'),helper);
        //helper.saveRecords(component,draftNewList,helper);
    },
})