/**
 * Wrapper class to hold cre pool details
 */
public class PoolDetail {
    public String poolId {get; set;}
    public String language {get; set;}
    public List<String> extensions {get; set;}

    public PoolDetail() {
        this.poolId = '';
        this.language = 'English';
        this.extensions = new List<String>();
    }

    public PoolDetail(String poolId) {
        this.poolId = poolId;
        this.language = 'English';
        this.extensions = new List<String>();
    }

    public PoolDetail(String poolId, String language, List<String> extensions) {
        this.poolId = poolId;
        this.language = language;
        this.extensions = extensions;
    }

    public void setExtensions(List<String> extensions) {
        this.extensions = extensions;
    }

    /**
     * Method to get pool names from pool extensions
     */
    public static List<String> getPoolNames(List<String> poolExtensions) {
        List<String> poolNames = new List<String>();
        Map<String, String> extensionToPoolName = getExtensionsToPoolName();
        for (String poolExteinsion : poolExtensions) {
            if (extensionToPoolName.get(poolExteinsion) != null) {
                poolNames.add(extensionToPoolName.get(poolExteinsion));
            }
        }
        return poolNames;
    }

    /**
     * Method to get map of extension to the cre pool names
     */
    public static Map<String, String> getExtensionsToPoolName() {
        Map<String, String> extensionToPoolName = new Map<String, String>();
        List<CRE_Pool_Detail__c> crePoolDetails = CRE_Pool_Detail__c.getall().values();
        for (CRE_Pool_Detail__c crePoolDetail : crePoolDetails) {
            extensionToPoolName.put(crePoolDetail.Extension__c, crePoolDetail.Pool_Name__c);
        }
        return extensionToPoolName;
    }

    /**
     * Method to get user pool details
     */
    public static List<PoolDetail> getPoolDetails(List<String> poolNames) {
        List<PoolDetail> poolDetails = new List<PoolDetail>();
        Set<Id> userIds = new Set<Id>();

        List<Group> publicGroups =
            [
                SELECT
                    Id,
                    Name,
                    Type,
                    (
                        SELECT
                            Id,
                            GroupId,
                            UserOrGroupId
                        FROM
                            GroupMembers
                    )
                FROM
                    Group
                WHERE
                    Name IN :poolNames
            ];

            System.debug('======= publicGroups : ' + publicGroups);

        // Fecth all user ids
        for (Group groupRecord : publicGroups) {
            for (GroupMember groupMember : groupRecord.GroupMembers) {
                userIds.add(groupMember.UserOrGroupId);
            }
        }

        // Get all user records
        Map<Id, User> userMap = new Map<Id, User>(
            [
                SELECT
                    Id,
                    Name,
                    Extension
                FROM
                    User
                WHERE
                    Id IN :userIds
            ]
        );

        System.debug('======= userMap : ' + userMap);

        // Create pool detail instances
        for (Group groupRecord : publicGroups) {
            List<String> extensions = new List<String>();
//            PoolDetail poolDetail = new PoolDetail(groupRecord.Id);
            PoolDetail poolDetail = new PoolDetail(
                CRE_Pool_Detail__c.getInstance(groupRecord.Name).Extension__c
            );
            for (GroupMember groupMember : groupRecord.GroupMembers) {
                System.debug('>>>>>>> groupMember : ' + groupMember);
                extensions.add(userMap.get(groupMember.UserOrGroupId).Extension);
            }
            poolDetail.setExtensions(extensions);
            poolDetails.add(poolDetail);
        }

        System.debug('======= poolDetails : ' + poolDetails);
        return poolDetails;
    }
}