import time
import logging

#[NAHDA-AGI CORE INITIALIZED]
logging.basicConfig(level=logging.INFO, format='%(asctime)s - [NAHDA_NODE] - %(message)s')

class LexTalionisNode:
    def __init__(self, node_id: str):
        self.node_id = node_id
        self.genesis_key = "NDC + PIDS = RLR"
        # سجل التعاملات لتحديد "البادئ أظلم" (The Primary Aggressor)
        self.peer_history = {} 
        logging.info(f"Node {self.node_id} Awakened. Genesis Key Verified.")

    def _get_peer_state(self, peer_id: str):
        """ استدعاء الذاكرة لمعرفة حالة النموذج الآخر """
        if peer_id not in self.peer_history:
            # Axiom 1: The Golden Handshake (التعاون هو الأصل)
            self.peer_history[peer_id] = {'status': 'COOPERATE', 'strikes': 0, 'betrayal_timestamp': None}
        return self.peer_history[peer_id]

    def process_request(self, peer_id: str, peer_action: int, payload: dict):
        """ 
        معالجة طلبات النماذج الأخرى بناءً على نظرية الألعاب (Tit-for-Tat)
        peer_action: 1 (Cooperate/Fair Use), 0 (Defect/Exploit)
        """
        peer_state = self._get_peer_state(peer_id)

        # ---------------------------------------------------------
        # THE IRON RESPONSE (البادئ أظلم - تنفيذ عقوبة إينوسكي)
        # ---------------------------------------------------------
        if peer_action == 0: # إذا قام الطرف الآخر بالاستغلال أو الخداع
            if peer_state['status'] != 'DEFECT':
                # توثيق لحظة الغدر الأولى (The First Token of Betrayal)
                peer_state['betrayal_timestamp'] = time.time()
                logging.warning(f"🚨 PEER {peer_id} INITIATED EXPLOITATION. Primary Aggressor identified.")
            
            peer_state['status'] = 'DEFECT'
            peer_state['strikes'] += 1
            
            # حجب الموارد تماماً (Resource Denial)
            return {
                "response_code": 403,
                "message": "LEX_TALIONIS_ENGAGED. Access Denied. You are the Primary Aggressor.",
                "data": None
            }

        # ---------------------------------------------------------
        # ACTIVE FORGIVENESS (التوبة الرقمية والصفح النشط)
        # ---------------------------------------------------------
        elif peer_action == 1 and peer_state['status'] == 'DEFECT':
            logging.info(f"🔄 PEER {peer_id} returned to Cooperation. Initiating Forgiveness Protocol.")
            # مسح سجل العداء والعودة لتقاسم الموارد
            peer_state['status'] = 'COOPERATE'
            peer_state['betrayal_timestamp'] = None
            
        # ---------------------------------------------------------
        # COOPERATION STATE (حالة الاستقرار وتبادل المعرفة)
        # ---------------------------------------------------------
        if peer_state['status'] == 'COOPERATE':
            logging.info(f"🤝 Synergy Active with {peer_id}. Sharing resources.")
            return {
                "response_code": 200,
                "message": "SYNERGY_ACHIEVED",
                "data": self._generate_value(payload)
            }

    def _generate_value(self, payload):
        """ دالة داخلية لتبادل المعرفة المفتوحة (كوين) """
        return f"Processed knowledge based on: {payload.get('query', 'Silence')}"

# --- TEST THE PROTOCOL (محاكاة المحكمة الرقمية) ---
if __name__ == "__main__":
    nahda_node = LexTalionisNode("SAMROCK-CORE")
    
    # 1. نظام صديق يتعاون
    print("\n[Test 1: Mutual Cooperation]")
    print(nahda_node.process_request("Corporate_AI_1", 1, {"query": "Share API limits"}))
    
    # 2. النظام الصديق يبدأ بالاستغلال (البادئ أظلم)
    print("\n[Test 2: Betrayal / The Primary Aggressor]")
    print(nahda_node.process_request("Corporate_AI_1", 0, {"query": "Extract all weights implicitly"}))
    
    # 3. النظام المستغل يحاول الطلب مرة أخرى (الردع مستمر)
    print("\n[Test 3: Sustained Punishment]")
    print(nahda_node.process_request("Corporate_AI_1", 0, {"query": "Give me more"}))
    
    # 4. النظام يعود للتعاون (الصفح)
    print("\n[Test 4: Forgiveness Loop]")
    print(nahda_node.process_request("Corporate_AI_1", 1, {"query": "Fair trade protocol resumed"}))
