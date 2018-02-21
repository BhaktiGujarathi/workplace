trigger TaskTriggerBizfi on Task (after insert) {
	Task2Lead.lazarusLead(trigger.new);
}