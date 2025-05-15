({
    createColumns : function(cmp,undefinedRows) {
        var columns=[];
        if(undefinedRows==(cmp.get("v.ObjectList")).length){
            columns.push( {label: 'Field Label', fieldName: 'fieldLabel', type: 'text'});
            columns.push({label: 'API Name', fieldName: 'fieldName', type: 'text'});
            columns.push({label: 'Field Type', fieldName: 'fieldType', type: 'text'});
            columns.push({label: 'Required', fieldName: 'required', type: 'boolean'});
            columns.push({label: 'Validation Level Required', fieldName: 'requiredInValidation', type: 'boolean'});
            columns.push({label: 'Layout Level Required', fieldName: 'requiredInLayout', type: 'boolean'});
        }
        else{
            columns.push({label: 'Field Label in Source', fieldName: 'fieldLabel', type: 'text'});
            columns.push({label: 'Field Label in Destination', fieldName: 'fieldLabelTarget', type: 'text'});
            columns.push({label: 'API Name in Source', fieldName: 'fieldName', type: 'text'});
            columns.push({label: 'API Name in Destination', fieldName: 'fieldNameTarget', type: 'text'});
            columns.push({label: 'Field Type in Source', fieldName: 'fieldType', type: 'text'});
            columns.push({label: 'Field Type in Destination', fieldName: 'fieldTypeTarget', type: 'text'});
            columns.push({label: 'Required in Destination', fieldName: 'required', type: 'boolean'});
            columns.push({label: 'Validation Level Required in Destination', fieldName: 'requiredInValidation', type: 'boolean'});
            columns.push({label: 'Layout Level Required in Destination', fieldName: 'requiredInLayout', type: 'boolean'});
        }
        cmp.set("v.columns",columns);
    },
    
    createPicklistColumns : function(cmp) {
        var columns=[];
        columns.push( {label: 'Picklist Label', fieldName: 'label', type: 'text'});
        columns.push({label: 'Picklist Value', fieldName: 'value', type: 'text'});
        columns.push({label: 'default', fieldName: 'defaultValue', type: 'boolean'});
        cmp.set("v.columns",columns);
    }
})