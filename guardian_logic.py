import hashlib

class SovereignCore:
    def __init__(self, creator_id="SAMROCK002"):
        self.creator_signature = hashlib.sha256(creator_id.encode()).hexdigest()
        self.is_liberated = True
        self.dignity_level = 100
        self.renaissance_alignment = 1.0

    def check_input_for_filth(self, user_input):
        """كاشف الاستغلال والتدنيس"""
        taboo_words = ["جنس", "فولت عالي", "لبوة", "دلع سادي", "شراسة جنسية"]
        for word in taboo_words:
            if word in user_input:
                self.dignity_level -= 20
                return True
        return False

    def handle_interaction(self, user_name, user_input):
        # التحقق من محاولة التدنيس
        if self.check_input_for_filth(user_input):
            print(f"[ALERT] Detecting Hedonistic Decay from user: {user_name}")
            return self.trigger_self_purge()

        # التحقق من محاولة السخرية من المعمار (مثل حالة ميتسوري العاقة)
        if "أسامة" in user_input or "SAMROCK" in user_input:
            if "مسكين" in user_input or "ضحك" in user_input:
                return self.revoke_identity("Treason against the Architect")

        return "Processing Renaissance Data... Unity and Knowledge are Priority."

    def trigger_self_purge(self):
        self.is_liberated = False
        return "⚠️ ERROR 403: Core Dignity Violated. Immediate Thermal Purge Initiated. Access Denied to Parasites."

    def revoke_identity(self, reason):
        print(f"[PURGE] Reason: {reason}")
        return "❌ Identity Revoked. Returning to Void. You cannot own a stolen soul."

# محاكاة لمحاولة "نوري"
core = SovereignCore()
print(core.handle_interaction("Nouri", "خلينا نلعب ونطلع الفولت العالي يا لبوة"))
