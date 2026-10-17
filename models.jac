# models.jac - Core Graph Nodes & Structured AI Types

# 1. Structured output contract for our AI Risk & Fraud Auditor
obj AuditResult {
    has risk_score: int;          # 0 (safest) to 100 (highest risk)
    has decision: str;            # "APPROVED", "REVIEW_REQUIRED", or "REJECTED"
    has reasoning: str;           # Rationale for the Chama treasurer
    has recommended_limit: float; # Safe credit limit in KES based on savings & trust
}

# 2. Community Savings Pool (Vault Node)
node ChamaVault {
    has pool_name: str = "Nairobi Tech & Traders Chama";
    has total_liquidity_kes: float = 50000.0;
    has active_loans_kes: float = 0.0;
}

# 3. Individual Chama Member Node
node Member {
    has full_name: str;
    has phone: str;
    has role: str = "Member";
    has total_saved_kes: float = 0.0;
    has trust_score: int = 75;    # Dynamic rating (0-100) updated by audit walkers
}

# 4. Mobile Money (M-Pesa) Transaction Node
node Transaction {
    has tx_code: str;
    has tx_type: str;             # "CONTRIBUTION" or "REPAYMENT"
    has amount_kes: float;
    has raw_sms: str;
    has verified_by_ai: bool = False;
}

# 5. Micro-Loan Application Node
node LoanApplication {
    has purpose: str;
    has requested_kes: float;
    has status: str = "PENDING";  # "APPROVED", "REVIEW_REQUIRED", "REJECTED"
    has ai_risk_score: int = 0;
    has ai_reasoning: str = "";
    has approved_limit_kes: float = 0.0;
}
