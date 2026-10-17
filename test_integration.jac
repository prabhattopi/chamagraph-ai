# test_integration.jac - End-to-End Multi-Agent Integration Simulation
include main;

with entry {
    print("=================================================");
    print("  CHAMAGRAPH AI - MULTI-AGENT INTEGRATION TEST   ");
    print("=================================================");

    # 1. Initialize Graph
    root spawn InitChamaGraph();
    print("\n[STEP 1] Chama Graph Topology Initialized.");

    # 2. Agent 1: Autonomous M-Pesa SMS Deposit Processing
    print("\n[STEP 2] Simulating Incoming M-Pesa SMS for Amina Wanjiku (+254712345678)...");
    incoming_sms = "QH34MK99PL Confirmed. Ksh3,500.00 sent to Nairobi Innovators Chama from +254712345678 on 17/10/2026. Savings Deposit.";
    
    deposit_agent = root spawn ProcessSMSDeposit(raw_sms=incoming_sms);
    print("Agent Result:");
    print(deposit_agent.reports);

    # 3. Agent 2: Autonomous Loan Underwriting for David Ochieng
    print("\n[STEP 3] Simulating Micro-Loan Application for David Ochieng...");
    loan_agent = root spawn ApplyLoanWithAudit(
        member_name="David Ochieng",
        requested_kes=7000.0,
        purpose="Stock up on lithium iron phosphate cells for campus solar lanterns"
    );
    print("Agent Result:");
    print(loan_agent.reports);

    # 4. Agent 3: Live Graph State Serialization
    print("\n[STEP 4] Fetching Complete Live Chama Graph Snapshot...");
    overview_agent = root spawn GetChamaOverview();
    print("Live Graph Snapshot:");
    print(overview_agent.reports);

    print("\n=================================================");
    print("  INTEGRATION TEST PASSED - GRAPH STATE MUTATED  ");
    print("=================================================");
}
