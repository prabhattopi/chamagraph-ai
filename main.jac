# main.jac - Entry Point & Phase 1 Graph Topology Verification
include models;

walker InitChamaGraph {
    can setup with entry {
        existing_vaults = [n for n in [-->] if isinstance(n, ChamaVault)];
        if len(existing_vaults) > 0 {
            visit existing_vaults[0];
        } else {
            # Spawn new ChamaVault attached to graph root
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
        members_list = [m for m in [-->] if isinstance(m, Member)];
        report {
            "status": "ChamaGraph Initialized",
            "vault_name": here.pool_name,
            "liquidity_kes": here.total_liquidity_kes,
            "member_count": len(members_list),
            "members": [
                {
                    "name": m.full_name,
                    "role": m.role,
                    "saved_kes": m.total_saved_kes,
                    "trust_score": m.trust_score
                } for m in members_list
            ]
        };
    }
}

with entry {
    result = root spawn InitChamaGraph();
    print("=== PHASE 1 GRAPH TEST OUTPUT ===");
    print(result.reports);
}
