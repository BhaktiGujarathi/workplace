trigger ProgramMasterTrigger on ProgramMaster__c (before delete, before update) {

    PreventProgramMasterOperation programMaster = new PreventProgramMasterOperation();
    programMaster.preventProgramMaster();
}