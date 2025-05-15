**Bulk metadata activator** 
 * This app allows users to activate/deactivate workflow rules, validation rules, assignment rules in bulk without much downtime for deploying the components.
 * This application can be used whenever we need to do a bulk data load job and dont want to fire any rules for it.


**\Data archival application** 
 * This application allows users to archive records from any custom or standard objects and allows for unarchiving the records. It also provides a way to visualize the amount of data archived segregated by the object Name using a dashboard. 
 * Archiving is done by selecting a parent object and running a batch by providing appropriate filters. Once the batch is submitted for parent, we can run the batch for the child object records and the 2nd level of child objects.
 * Upto 2 levels of child object records can be traversed and archived.
 
**Data migration application** 
 * This application is seperated into the components that needs to be deployed into source org and destination orgs. 
 * This application is used for migrating standard and custom object records from one salesforce org to another along with all parent object records in the hierarchy. 
 * It also provides a save and commit mechanism where the users can first run jobs to move the records to target org and then commit them to database when all the records in the hierarchy are moved by specifying the commit order.


**Data migration assistant** 
 * This application is seperated into the components that needs to be deployed into source org and destination orgs.
 * This tool allows admins to compare fields, check if the field is required in target org (validation, layout and object level) and picklist values between orgs and get a pdf document of the same. 
 * The tool allows for users to select the object and get the field and picklist details from that object’s parent and optionally child objects.


 **Email archival application** 
 * Similar to Data archival application this app is used to archive emails that are attached to the cases.
 * All the data which are archived are saved in big objects. Upto 10 million records can be archived for free.
 * Email unarhcival is also supported which will unarchive the records and add it back to the parent cases.


**Sandbox refresh assistant** 
 * This application is seperated into the components that needs to be deployed into source org and destination orgs. 
 * We Built an application that allows an admin to take backup of all the custom setting records inside a zip file and push it into production where it can be safe until the refresh happens where it will come back to the sandbox.
 * The admin can use this zip file to update all the custom setting records directly or can also perform a conflict with the existing settings and merge/ edit the backup before loading the data.
 * This also includes a tab to take backup for all metadata and deploy it to the sandbox post refresh.
 * A data anonymizing tool is included which will allow users to select the object and fields that contains personal information and fill those with junk. Upto 5 selections are saved as user preferences for future use.
 * The application has a tab to abort all the running jobs in sandbox to avoid any automated field updates and emails to be triggered.


**Screen recorder application**  
 * This app allows users to record the issues on the screen and create a salesforce case/ Service now  using a button on the page. 
 * The code can be modified to integrate any other incident management system.

  
**Screen recorder chat application** 
 * This app is a upgraded version of the recorder application which allows user to create the cases through an interactive chat. 
 * The code can be modified to integrate any other incident management system and the chat settings can be customized.
 * There is also an admin screen which can be used to set up the questions for the chat application where users can enter the case related details and submit it.

  

  

  