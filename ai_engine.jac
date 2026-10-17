# ai_engine.jac - Provider-Agnostic LLM Micro-Finance Reasoning Engine
import os;
import from byllm.lib { Model }
include models;

# Provider-agnostic initialization:
# Defaults to Gemini Free tier, or override via AI_MODEL env var
glob selected_model: str = os.getenv("AI_MODEL", "gemini/gemini-2.5-flash");
glob llm = Model(model_name=selected_model);

# AI Skill 1: Extract structured M-Pesa transaction details from raw SMS text
def parse_mpesa_sms(raw_sms: str) -> ParsedSMS by llm();

# AI Skill 2: Contextual Underwriting for Community Micro-Loans
def underwrite_loan_request(
    member_name: str,
    total_saved_kes: float,
    trust_score: int,
    vault_liquidity_kes: float,
    requested_amount_kes: float,
    loan_purpose: str
) -> AuditResult by llm();
