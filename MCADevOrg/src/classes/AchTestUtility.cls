public class AchTestUtility{
    public Achworkscom.ACHReturnRecord getTestReturn(string trace){
        Achworkscom.ACHReturnRecord rec = new Achworkscom.ACHReturnRecord();
        rec.FrontEndTrace = trace;
        rec.ResponseCode = '9BK';
        rec.EffectiveDate = Datetime.now().date();
        rec.ActionDate = Datetime.now().date();
        rec.ActionDetail = 'Charge Back';
        rec.TransAmount = 0.01;
        rec.CustomerName = 'test customer';
        rec.SourceFile = 'testxmlfile';
        return rec;
    }
}