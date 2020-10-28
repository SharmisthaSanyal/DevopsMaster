trigger T_Lead on Lead (after update) {
  if(Trigger.isAfter && Trigger.isUpdate) {
    H_Lead.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
  }
}