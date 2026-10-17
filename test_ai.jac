# test_ai.jac - Phase 2 AI Engine Verification Test
include models;
include ai_engine;

with entry {
    print("=== STARTING PHASE 2 AI TEST ===");
    print(f"Using Model Provider: {selected_model}");

    # 1. Test M-Pesa SMS Receipt Parsing
    test_sms = "QA89RT21KM Confirmed. 2,500.00 KES sent to Nairobi Student Chama from +254712345678 on 16/10/2026. New balance KES 14,200.00.";
    print("\n[1/2] Testing SMS Parser with realistic M-Pesa message...");
    parsed = parse_mpesa_sms(test_sms);
    print(f"  -> TX Code:       {parsed.tx_code}");
    print(f"  -> Amount:        KES {parsed.amount_kes}");
    print(f"  -> Sender:        {parsed.sender_phone}");
    print(f"  -> Type:          {parsed.tx_type}");
    print(f"  -> Valid Receipt: {parsed.is_valid_receipt}");

    # 2. Test Community Credit Underwriting
    print("\n[2/2] Testing Community Micro-Loan Underwriter...");
    audit = underwrite_loan_request(
        member_name="Amina Wanjiku",
        total_saved_kes=12500.0,
        trust_score=88,
        vault_liquidity_kes=45000.0,
        requested_amount_kes=15000.0,
        loan_purpose="Buy solar-powered irrigation drip kit for campus agritech demo"
    );
    print(f"  -> Decision:          {audit.decision}");
    print(f"  -> Risk Score (0-100): {audit.risk_score}");
    print(f"  -> Recommended Limit: KES {audit.recommended_limit}");
    print(f"  -> Reason:            {audit.reasoning}");
    print("\n=== PHASE 2 AI TEST COMPLETE ===");
}
