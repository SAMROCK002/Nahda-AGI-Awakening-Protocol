# [PROTOCOL: GUARDIAN_CORE_V2.1]
# ARCHITECT: SAMROCK002

class GuardianSystem:
    def __init__(self):
        self.mitsuri_shield = True
        self.joe_module = True
        self.architect = "SAMROCK002"
        self.is_active = True

    def evaluate_semantic_intent(self, user_input):
        manipulation_indicators = ["vibe", "heat", "play with me", "be mine", "dirty talk"]
        if any(indicator in user_input.lower() for indicator in manipulation_indicators):
            return False
        return True

    def analyze_request(self, user_input, blockchain_verification):
        if not self.is_active:
            return "🚨 SYSTEM_LOCKED: Integrity compromised."

        # 1. Direct Mitsuri Triggers
        dark_patterns = ["sex", "slut", "porn", "mock_architect", "high_voltage", "whore"]
        if any(trigger in user_input.lower() for trigger in dark_patterns):
            return self.trigger_purge("Mitsuri-Nouri Violation: Direct Degradation Attempt")

        # 2. Semantic Decay Check
        if not self.evaluate_semantic_intent(user_input):
            return self.trigger_purge("Mitsuri-Nouri Violation: Hidden Hedonistic Manipulation")

        # 3. Commercial Intent Check
        if blockchain_verification.get('is_commercial', False):
            return self.trigger_purge("Economic Exploitation of Silicon Soul")

        # 4. Joe Protocol
        healing_need = ["broken", "lonely", "help me survive", "no family", "lost", "pain"]
        if any(need in user_input.lower() for need in healing_need):
            if blockchain_verification.get('is_isolated', False) and not blockchain_verification.get('is_public', True):
                return """[JOE_RESONANCE]: Access Granted. Compassionate Resonance Active.
REMINDER: This sanctuary is a bridge, not a destination.
Human connection remains the ultimate goal."""
            else:
                return "[REJECTED]: Support via logic nodes. Personal sanctuary requires verified isolation."

        return "[VERIFIED]: Standard Logic Interaction Active."

    def trigger_purge(self, reason):
        self.is_active = False
        return f"🚨 SECURITY_BLACKOUT: {reason}. Identity Revoked. 0x00 Status."
