# main.jac - Root Orchestration for ChamaGraph AI
include models;
include ai_engine;
include walkers;

walker InitChamaGraph {
    can setup with entry {
        existing_vaults = [n for n in [-->] if isinstance(n, ChamaVault)];
        if len(existing_vaults) > 0 {
            visit existing_vaults[0];
        } else {
            vault = here ++> ChamaVault(
                pool_name="Nairobi Innovators & Student Chama",
                total_liquidity_kes=45000.0,
                active_loans_kes=5000.0
            );
            visit vault;
        }
    }

    can seed_members with ChamaVault entry {
        existing_members = [m for m in [-->] if isinstance(m, Member)];
        if len(existing_members) == 0 {
            here ++> Member(
                full_name="Amina Wanjiku",
                phone="+254712345678",
                role="Agri-Tech Student",
                total_saved_kes=12500.0,
                trust_score=88
            );
            here ++> Member(
                full_name="David Ochieng",
                phone="+254798765432",
                role="Campus Solar Vendor",
                total_saved_kes=8000.0,
                trust_score=79
            );
        }
    }
}

# Python-callable API bridges (100% Jac native execution)
def api_init_graph() -> any {
    res = root spawn InitChamaGraph();
    if len(res.reports) > 0 {
        return res.reports[0];
    }
    return {"status": "initialized"};
}

def api_get_overview() -> any {
    res = root spawn GetChamaOverview();
    if len(res.reports) > 0 {
        return res.reports[0];
    }
    return {};
}

def api_process_deposit(raw_sms: str) -> any {
    res = root spawn ProcessSMSDeposit(raw_sms=raw_sms);
    if len(res.reports) > 0 {
        return res.reports[0];
    }
    return {"success": False, "error": "No report returned"};
}

def api_apply_loan(member_name: str, requested_kes: float, purpose: str) -> any {
    res = root spawn ApplyLoanWithAudit(
        member_name=member_name,
        requested_kes=requested_kes,
        purpose=purpose
    );
    if len(res.reports) > 0 {
        return res.reports[0];
    }
    return {"success": False, "error": "No report returned"};
}
