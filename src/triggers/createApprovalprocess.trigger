trigger createApprovalprocess on Account (before insert) {
for(Account acc : Trigger.new){
if(acc.AnnualRevenue > 1000)
submitforapproval(acc);
else
rejectapprovalreq(acc);

}
public void submitforapproval(Account account){
Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();

        req.setComments('Approving request using Trigger');

        req.setAction('Approve');

        req.setNextApproverIds(new Id[] {account.OwnerId });
        // Submit the request for approval

            Approval.ProcessResult result =  Approval.process(req);


}
public void rejectapprovalreq(Account account){
Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();

        req.setComments('Rejected request using Trigger');

        req.setAction('Reject');
        // Submit the request for approval

            Approval.ProcessResult result =  Approval.process(req);




}

}