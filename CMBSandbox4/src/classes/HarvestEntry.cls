public class HarvestEntry {
    public Integer Id { get; set; }
    public String ProjectCode { get; set; }
    public String Task { get; set; }
    public Double Hours { get; set; }
    public String Notes { get; set; }
    public Date SpentAt { get; set; }
    public String Person { get; set; }
    public Boolean IsClosed { get; set; }
    public Boolean IsBilled { get; set; }
}