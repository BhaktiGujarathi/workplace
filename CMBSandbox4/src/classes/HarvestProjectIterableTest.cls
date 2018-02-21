@isTest
private class HarvestProjectIterableTest {

	@isTest
	static void test() {
		HarvestProjectIterable iter = new HarvestProjectIterable();
		System.assert(iter.Iterator() != null);
	}
}