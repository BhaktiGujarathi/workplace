global class DETE_OccupationCodeSchedular implements Schedulable {
   global void execute(SchedulableContext schedulContext) {
      DETE_OccupationCode batchCls = new DETE_OccupationCode(); 
      database.executebatch(batchCls);
   }
}