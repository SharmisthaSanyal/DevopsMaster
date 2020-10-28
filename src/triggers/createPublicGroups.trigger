trigger createPublicGroups on Account (after insert) {
List<Group> grouplist_country = new List<Group>();
List<Group> grouplist_state = new List<Group>();
List<String> finalgrouplisttocheck = new List<String>();

List<GroupMember> memberList = new List<GroupMember>();



for(Account acc : trigger.new){
Group grp =new Group();
if(String.isNotBlank(acc.BillingCountry))
  {
grp.name = acc.BillingCountry;
grouplist_country.add(grp);
  }
  else if(String.isNotBlank(acc.BillingState)){
  grp.name = acc.BillingState;
  grouplist_state.add(grp);
  }
  finalgrouplisttocheck.add(acc.BillingCountry);
  finalgrouplisttocheck.add(acc.BillingState);
}
List<Group> fnlcntyset = new List<Group>();
List<Group> fnlstateyset = new List<Group>();
List<Group> grpexists= [select Id,Name from Group where name in: finalgrouplisttocheck  ];
if(grpexists.size()>0){
for(Group extgrp : grpexists){
for(Group grp1 :grouplist_country){
if(extgrp.name != grp1.name)
{  
Group grp = new Group();
grp.name = grp1.name;
fnlcntyset.add(grp);
}

}

}

for(Group extgrp : grpexists){
for(Group grp1 :grouplist_state){
if(extgrp.name != grp1.name)
{  
Group grp = new Group();
grp.name = grp1.name;
fnlstateyset.add(grp);
}

}

}

}

try{ if(fnlcntyset.size()>0)
insert fnlcntyset; 
}catch(Exception e){}
try{
if(fnlstateyset .size()>0)
insert fnlstateyset ; 
}catch(Exception e){}
 for(Group grpst: fnlstateyset){
for(Group grp : fnlcntyset){
GroupMember grpmember = new GroupMember();
grpmember.groupId = grpst.id;
grpmember.UserOrGroupId = grp.id;
memberList.add(grpmember);
  }
}

try{
if(memberList.size()>0)
insert memberList;
}catch(Exception e){}

}