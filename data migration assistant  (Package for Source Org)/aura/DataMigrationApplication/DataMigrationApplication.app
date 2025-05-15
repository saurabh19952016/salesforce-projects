<aura:application extends="force:slds">
        <div class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_info slds-text-align_left" aura:id="alert" role="alert">
        <lightning:icon iconName="utility:info" variant="inverse" size="small" class="slds-m-right--large"/>
        <ul class="slds-list--dotted">
            <li>
                <h2>
                    1. Select the object to generate the report. To generate report for a new object click on reset and wait until the job is completed.
                </h2>
            </li>
            <li>
                <h2>
                    2. Select if child object data needs to be retrieved.
                </h2>
            </li>
            <li>
                <h2>
                    3. Select if the migration is from SFDC to SFDC or from an external database.
                </h2>
            </li>
            <li>
                <h2>
                    4. Select if you are going to disable the validation rules.
                </h2>
            </li>
            <li>
                <h2>
                    5. Submit the job and wait few minutes for it to complete.
                </h2>
            </li>
            <li>
                <h2>
                    6. Once Job is completed you can see the parent and child object details based on the selection.
                </h2>
            </li>
             <li>
                <h2>
                    8. You can print the parent object by selecting 'Parent Objects' button and clicking on print button.
                </h2>
            </li>
 			<li>
                <h2>
                    8. You can print the child object by selecting 'Child Objects' button and clicking on print button.
                </h2>
            </li>
        </ul>
        <div class="slds-notify__close">
            <lightning:icon iconName="utility:close"  variant="inverse" onclick="{!c.close}"/>
        </div>
    </div>   
   <c:DataMigrationDocumentGeneration/> 
</aura:application>