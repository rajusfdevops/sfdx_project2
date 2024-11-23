trigger ProjectTrigger on Project__c (before insert, before update) {
    for (Project__c project : Trigger.new) {
        if (project.End_Date__c < project.Start_Date__c) {
            project.addError('End Date cannot be before Start Date.');
        }
    }
}