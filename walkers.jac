# walkers.jac - Autonomous Agent Walkers for ChamaGraph AI
include models;
include ai_engine;

# Walker 1: Parses M-Pesa SMS, credits Vault liquidity, and updates Member savings
walker ProcessSMSDeposit {
    has raw_sms: str;
    has parsed_tx: ParsedSMS = None;

    can start with entry {
        self.parsed_tx = parse_mpesa_sms(self.raw_sms);
        if not self.parsed_tx.is_valid_receipt {
            report {
                "success": False,
                "error": "Invalid or fraudulent M-Pesa receipt format"
            };
            disengage;
        }

        vaults = [n for n in [-->] if isinstance(n, ChamaVault)];
        for v in vaults {
            visit v;
        }
    }

    can update_vault_and_find_member with ChamaVault entry {
        here.total_liquidity_kes += self.parsed_tx.amount_kes;

        members = [m for m in [-->] if isinstance(m, Member)];
        matched = False;
        for m in members {
            if m.phone == self.parsed_tx.sender_phone {
                matched = True;
                visit m;
            }
        }

        if not matched {
            report {
                "success": True,
                "warning": "Vault credited, but sender phone not registered to an existing member",
                "tx_code": self.parsed_tx.tx_code,
                "amount_kes": self.parsed_tx.amount_kes,
                "vault_new_liquidity": here.total_liquidity_kes
            };
        }
    }

    can credit_member with Member entry {
        # Attach verified Transaction node to this Member
        here ++> Transaction(
            tx_code=self.parsed_tx.tx_code,
            tx_type=self.parsed_tx.tx_type,
            amount_kes=self.parsed_tx.amount_kes,
            raw_sms=self.raw_sms,
            verified_by_ai=True
        );

        # Update member savings and increment trust score
        here.total_saved_kes += self.parsed_tx.amount_kes;
        here.trust_score = min(100, here.trust_score + 2);

        report {
            "success": True,
            "action": "DEPOSIT_VERIFIED",
            "member_name": here.full_name,
            "tx_code": self.parsed_tx.tx_code,
            "amount_kes": self.parsed_tx.amount_kes,
            "updated_savings_kes": here.total_saved_kes,
            "updated_trust_score": here.trust_score
        };
    }
}

# Walker 2: Evaluates loan requests using LLM underwriter and updates graph state
walker ApplyLoanWithAudit {
    has member_name: str;
    has requested_kes: float;
    has purpose: str;

    can start with entry {
        vaults = [n for n in [-->] if isinstance(n, ChamaVault)];
        for v in vaults {
            visit v;
        }
    }

    can underwrite_and_disburse with ChamaVault entry {
        vault = here;
        members = [m for m in [-->] if isinstance(m, Member) and m.full_name == self.member_name];

        if len(members) == 0 {
            report {
                "success": False,
                "error": f"Member '{self.member_name}' does not exist in this Chama"
            };
            disengage;
        }

        applicant = members[0];

        audit = underwrite_loan_request(
            member_name=applicant.full_name,
            total_saved_kes=applicant.total_saved_kes,
            trust_score=applicant.trust_score,
            vault_liquidity_kes=vault.total_liquidity_kes,
            requested_amount_kes=self.requested_kes,
            loan_purpose=self.purpose
        );

        applicant ++> LoanApplication(
            purpose=self.purpose,
            requested_kes=self.requested_kes,
            status=audit.decision,
            ai_risk_score=audit.risk_score,
            ai_reasoning=audit.reasoning,
            approved_limit_kes=audit.recommended_limit
        );

        is_approved = "APPROVE" in audit.decision.upper();
        if is_approved {
            disbursed_amount = min(self.requested_kes, audit.recommended_limit);
            vault.total_liquidity_kes -= disbursed_amount;
            vault.active_loans_kes += disbursed_amount;
        }

        report {
            "success": True,
            "action": "LOAN_AUDITED",
            "applicant": applicant.full_name,
            "requested_kes": self.requested_kes,
            "decision": audit.decision,
            "risk_score": audit.risk_score,
            "approved_limit_kes": audit.recommended_limit,
            "reasoning": audit.reasoning,
            "vault_remaining_liquidity": vault.total_liquidity_kes,
            "vault_active_loans": vault.active_loans_kes
        };
    }
}

# Walker 3: Gathers deep live snapshot of the entire multi-agent graph
walker GetChamaOverview {
    has overview: dict = {};

    can start with entry {
        vaults = [n for n in [-->] if isinstance(n, ChamaVault)];
        for v in vaults {
            visit v;
        }
    }

    can inspect_vault with ChamaVault entry {
        self.overview = {
            "pool_name": here.pool_name,
            "total_liquidity_kes": here.total_liquidity_kes,
            "active_loans_kes": here.active_loans_kes,
            "members": []
        };

        members = [m for m in [-->] if isinstance(m, Member)];
        for m in members {
            txs = [t for t in [m-->] if isinstance(t, Transaction)];
            loans = [l for l in [m-->] if isinstance(l, LoanApplication)];

            member_record = {
                "name": m.full_name,
                "phone": m.phone,
                "role": m.role,
                "saved_kes": m.total_saved_kes,
                "trust_score": m.trust_score,
                "recent_transactions": [
                    {"code": t.tx_code, "type": t.tx_type, "amount": t.amount_kes} for t in txs
                ],
                "loans": [
                    {"purpose": l.purpose, "requested": l.requested_kes, "status": l.status, "risk": l.ai_risk_score} for l in loans
                ]
            };
            self.overview["members"].append(member_record);
        }

        report self.overview;
    }
}
